#!/usr/bin/env bash
# Read-only inventory of the data on eol-archive, before the server is rebuilt.
# For each folder it lists the sub-folders (size, number of files, newest file), symlinks that point
# outside the folder, the files inside the code trees that are not in git, and the crontabs.
# It changes nothing: it only reads, and writes its report to a new folder.
#
# Usage:  bash eol-archive-inventory.sh [PATH[=LABEL] ...]
#   No arguments: /var/www/html=webroot  /extra=extra  /html=html  (those that exist).
#   Run it the same way on a copy (backup disk, Mac, new server), with the same labels, then compare:
#     bash eol-inventory-compare.sh <eol-archive report folder> <copy report folder>
# Settings (environment):
#   DEPTH=3                  folder levels listed (default 3)
#   OUT=/path/report_folder  default: ~/eol_inventory_<host>_<date>
# On eol-archive run it with sudo, so no folder is skipped for permissions. Works on RHEL 7 and macOS.
# Big trees take a while; it runs at low CPU/disk priority.

set -u
DEPTH=${DEPTH:-3}
HOST=$(hostname -s 2>/dev/null || hostname)
OUT=${OUT:-$HOME/eol_inventory_${HOST}_$(date +%Y%m%d_%H%M)}

if [ "$#" -eq 0 ]; then
    for p in /var/www/html=webroot /extra=extra /html=html; do
        [ -d "${p%%=*}" ] && set -- "$@" "$p"
    done
fi
[ "$#" -gt 0 ] || { echo "Nothing to inventory: pass PATH[=LABEL] arguments." >&2; exit 1; }

if [ -e "$OUT" ]; then echo "Report folder already exists: $OUT" >&2; exit 1; fi
umask 077   # the report may show crontab commands and file names; keep it private
mkdir -p "$OUT" || exit 1

# Low priority, so the live site isn't slowed down
renice -n 19 $$ >/dev/null 2>&1
command -v ionice >/dev/null 2>&1 && ionice -c3 -p $$ >/dev/null 2>&1

if find / -maxdepth 0 -printf '' >/dev/null 2>&1; then GNU_FIND=1; else GNU_FIND=0; fi

fmt_date() {  # epoch → YYYY-MM-DD HH:MM
    [ -n "$1" ] && [ "$1" != 0 ] || { echo "-"; return; }
    date -d "@$1" '+%Y-%m-%d %H:%M' 2>/dev/null || date -r "$1" '+%Y-%m-%d %H:%M'
}

human() {  # bytes → 1.2G
    awk -v b="$1" 'BEGIN { split("B K M G T P", u, " "); i = 1; while (b >= 1024 && i < 6) { b /= 1024; i++ }
                           printf (i == 1 ? "%d%s" : "%.1f%s"), b, u[i] }'
}

list_entries() {  # type<TAB>bytes<TAB>mtime<TAB>relative path; follows only the root itself if it is a symlink
    if [ "$GNU_FIND" = 1 ]; then
        find -H "$1" -mindepth 1 -printf '%y\t%s\t%T@\t%P\n' 2>>"$OUT/errors.txt"
    else
        (cd "$1" && find . -mindepth 1 -exec stat -f '%HT%t%z%t%m%t%N' {} + 2>>"$OUT/errors.txt") |
            awk -F'\t' 'BEGIN { OFS = "\t" }
                { t = ($1 == "Regular File") ? "f" : ($1 == "Directory") ? "d" : ($1 == "Symbolic Link") ? "l" : "o"
                  sub(/^\.\//, "", $4); print t, $2, $3, $4 }'
    fi
}

{
    echo "EOL data inventory (read-only)"
    echo "Host:    $HOST"
    echo "Date:    $(date '+%Y-%m-%d %H:%M %Z')"
    echo "User:    $(id -un)"
    echo "Depth:   $DEPTH folder levels"
    echo "Folders: $*"
    echo
    echo "== Disk space"
    for arg in "$@"; do df -h "${arg%%=*}" 2>/dev/null | tail -n +2; done | sort -u
} > "$OUT/summary.txt"

for arg in "$@"; do
    root=${arg%%=*}
    [ "$root" != / ] && root=${root%/}
    label=${arg#*=}; [ "$label" = "$arg" ] && label=$(basename "$root")
    if [ ! -d "$root" ]; then echo "SKIPPED (not a folder): $root" | tee -a "$OUT/summary.txt" >&2; continue; fi
    echo "Scanning $root ..." >&2

    # LABEL.tsv: path, type (d = folder, l = symlink), bytes, files, newest file (epoch), symlink target.
    # Folder rows count everything below them; "." is the whole tree.
    list_entries "$root" | awk -F'\t' -v depth="$DEPTH" '
        BEGIN { OFS = "\t" }
        {
            type = $1; size = $2 + 0; mt = int($3); path = $4
            n = split(path, parts, "/")
            if (type == "d" && n <= depth) key[path] = 1
            if (type == "l") { links++; if (n <= depth) lk[path] = 1 }
            if (type != "f") next
            totb += size; totn++; if (mt > totm) totm = mt
            p = ""
            for (i = 1; i < n && i <= depth; i++) {
                p = (i == 1) ? parts[1] : p "/" parts[i]
                key[p] = 1; b[p] += size; c[p]++; if (mt > m[p]) m[p] = mt
            }
        }
        END {
            print ".", "d", totb + 0, totn + 0, totm + 0, ""
            for (k in key) print k, "d", b[k] + 0, c[k] + 0, m[k] + 0, ""
            for (k in lk) print k, "l", "", "", "", ""
        }' | LC_ALL=C sort -t "$(printf '\t')" -k1,1 > "$OUT/$label.tsv.tmp"

    # Fill in symlink targets
    while IFS="$(printf '\t')" read -r path type bytes files newest target; do
        [ "$type" = l ] && target=$(readlink "$root/$path")
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$path" "$type" "$bytes" "$files" "$newest" "$target"
    done < "$OUT/$label.tsv.tmp" > "$OUT/$label.tsv"
    rm -f "$OUT/$label.tsv.tmp"

    total=$(awk -F'\t' '$1 == "." { print $3, $4, $5 }' "$OUT/$label.tsv")
    tb=${total%% *}; rest=${total#* }; tn=${rest%% *}; tm=${rest#* }
    {
        echo
        echo "== $label: $root"
        echo "Total: $(human "$tb") in $tn files, newest file $(fmt_date "$tm")"
        echo
        echo "Largest folders (levels 1-2):"
        awk -F'\t' '$2 == "d" && $1 != "." && split($1, a, "/") <= 2' "$OUT/$label.tsv" |
            sort -t "$(printf '\t')" -k3,3nr | head -40 |
            while IFS="$(printf '\t')" read -r path type bytes files newest target; do
                printf '  %8s  %9s files  newest %s  %s\n' "$(human "$bytes")" "$files" "$(fmt_date "$newest")" "$path"
            done
        echo
        echo "Symlinks (levels 1-$DEPTH; their targets are not counted above):"
        awk -F'\t' '$2 == "l" { printf "  %s -> %s\n", $1, $6 }' "$OUT/$label.tsv" | head -100
    } >> "$OUT/summary.txt"

    # Symlinks anywhere in the tree that point outside it: that data lives elsewhere and needs its own copy
    find -H "$root" -mindepth 1 -type l 2>/dev/null | while IFS= read -r l; do
        t=$(readlink "$l")
        case "$t" in
            /*) case "$t" in "$root"/*) ;; *) printf '%s -> %s\n' "${l#$root/}" "$t" ;; esac ;;
        esac
    done | LC_ALL=C sort > "$OUT/$label.links_outside.txt"
    {
        echo
        echo "Symlinks pointing outside $root: $(wc -l < "$OUT/$label.links_outside.txt" | tr -d ' ') (full list: $label.links_outside.txt)"
        head -30 "$OUT/$label.links_outside.txt" | sed 's/^/  /'
    } >> "$OUT/summary.txt"

    # Code trees (git checkouts) in the first 2 levels: what is in them but not in git (data, config, caches)
    command -v git >/dev/null 2>&1 || { echo; echo "git is not installed: files not in git were not listed."; } >> "$OUT/summary.txt"
    command -v git >/dev/null 2>&1 &&
    find -H "$root" -mindepth 2 -maxdepth 3 -name .git 2>/dev/null | while IFS= read -r g; do
        repo=$(dirname "$g")
        name=${repo#$root/}
        safe=$(echo "$name" | tr '/' '_')
        (cd "$repo" && git -c safe.directory='*' ls-files --others --directory --no-empty-directory 2>/dev/null) |
            while IFS= read -r e; do
                kb=$(du -sk "$repo/$e" 2>/dev/null | awk '{ print $1 }')
                printf '%s\t%s\n' "${kb:-0}" "$e"
            done | sort -t "$(printf '\t')" -k1,1nr > "$OUT/$label.not_in_git.$safe.tsv"
        {
            echo
            echo "Not in git in $name (largest first; full list: $label.not_in_git.$safe.tsv):"
            kbt=$(awk -F'\t' '{ t += $1 } END { print t + 0 }' "$OUT/$label.not_in_git.$safe.tsv")
            echo "  total $(human $((kbt * 1024))) in $(wc -l < "$OUT/$label.not_in_git.$safe.tsv" | tr -d ' ') entries"
            head -25 "$OUT/$label.not_in_git.$safe.tsv" | while IFS="$(printf '\t')" read -r kb e; do
                printf '  %8s  %s\n' "$(human $((kb * 1024)))" "$e"
            done
        } >> "$OUT/summary.txt"
    done
done

# Crontabs: scheduled jobs that exist only on this server. Values after password=/token=/key= are masked.
{
    if command -v perl >/dev/null 2>&1; then
        mask() { perl -pe 's/((?:pass(?:word)?|pwd|token|key|secret)[=:])[^\s&"\x27]+/$1***/gi'; }
    else  # GNU sed (Linux without perl)
        mask() { sed -E 's/((pass(word)?|pwd|token|key|secret)[=:])[^[:space:]&"'"'"']+/\1***/Ig'; }
    fi
    echo "== crontab of $(id -un)"
    crontab -l 2>&1 | mask
    if [ "$(id -u)" = 0 ]; then
        for f in /var/spool/cron/*; do
            [ -f "$f" ] || continue
            echo; echo "== crontab of $(basename "$f")"; mask < "$f"
        done
        echo; echo "== /etc/cron.d"; ls -l /etc/cron.d 2>&1
    fi
} > "$OUT/crontabs.txt"

errs=$(wc -l < "$OUT/errors.txt" 2>/dev/null | tr -d ' ')
{
    echo
    echo "== Other files in this report"
    echo "  crontabs.txt            scheduled jobs (secrets masked)"
    echo "  LABEL.tsv               every folder up to $DEPTH levels: path, type, bytes, files, newest (epoch), symlink target"
    echo "  errors.txt              ${errs:-0} lines (e.g. permission denied; run with sudo to avoid them)"
} >> "$OUT/summary.txt"

echo "Done. Report: $OUT/summary.txt" >&2
