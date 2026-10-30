#!/usr/bin/env bash
# Compare two report folders made by eol-archive-inventory.sh: the source (eol-archive) and a copy
# (backup disk, Mac, new server). Read-only. Lists only what differs:
#   MISSING        folder or symlink in the source, not in the copy (its sub-folders aren't repeated)
#   FEWER FILES    the copy has fewer files below this folder
#   SMALLER        same number of files, fewer bytes
#   NEWER          the source has a file newer than anything in the copy (changed after the copy was made;
#                  only meaningful if the copy kept file dates: rsync -a or cp -a)
#   LINK DIFFERS   symlink points somewhere else, or is a folder on one side and a symlink on the other
# Only labels present in both folders are compared (e.g. extra.tsv vs extra.tsv).
#
# Usage:  bash eol-inventory-compare.sh SOURCE_REPORT_FOLDER COPY_REPORT_FOLDER
# Exit code: 0 = copy has everything, 1 = differences found, 2 = usage error.

set -u
[ "$#" -eq 2 ] && [ -d "$1" ] && [ -d "$2" ] || { sed -n '2,13p' "$0" >&2; exit 2; }
SRC=$1; CPY=$2
diffs=0; compared=0

for s in "$SRC"/*.tsv; do
    [ -f "$s" ] || continue
    name=$(basename "$s")
    case "$name" in *.not_in_git.*) continue ;; esac
    c="$CPY/$name"
    if [ ! -f "$c" ]; then echo "== ${name%.tsv}: no matching report in the copy (skipped)"; continue; fi
    compared=$((compared + 1))
    echo "== ${name%.tsv}"
    out=$(awk -F'\t' '
        function human(b,   u, i) { split("B K M G T P", u, " "); i = 1; while (b >= 1024 && i < 6) { b /= 1024; i++ }
                                      return sprintf((i == 1 ? "%d%s" : "%.1f%s"), b, u[i]) }
        NR == FNR { ct[$1] = $2; cb[$1] = $3; cn[$1] = $4; cm[$1] = $5; cl[$1] = $6; next }
        {
            path = $1; type = $2
            if (gone != "" && index(path, gone "/") == 1) next      # inside a folder already reported missing
            if (!(path in ct)) {
                if (type == "l") print "MISSING        " path " -> " $6 "  (symlink)"
                else             print "MISSING        " path "  (" human($3) ", " $4 " files)"
                gone = path; next
            }
            if (type != ct[path]) {
                print "LINK DIFFERS   " path "  (source: " (type == "l" ? "symlink -> " $6 : "folder") \
                      ", copy: " (ct[path] == "l" ? "symlink -> " cl[path] : "folder") ")"
                next
            }
            if (type == "l") { if ($6 != cl[path]) print "LINK DIFFERS   " path "  (source -> " $6 ", copy -> " cl[path] ")"; next }
            if (cn[path] < $4)      print "FEWER FILES    " path "  (source " $4 ", copy " cn[path] ")"
            else if (cb[path] < $3) print "SMALLER        " path "  (source " human($3) ", copy " human(cb[path]) ")"
            if ($5 > cm[path] + 1)  print "NEWER          " path "  (source has newer files than the copy)"
        }' "$c" "$s")
    if [ -n "$out" ]; then
        echo "$out"; diffs=$((diffs + $(echo "$out" | wc -l)))
    else
        echo "OK: the copy has every folder, file count and byte"
    fi
done

[ "$compared" -gt 0 ] || { echo "No matching LABEL.tsv files in both folders." >&2; exit 2; }
echo
if [ "$diffs" -eq 0 ]; then echo "Result: the copy has everything."; exit 0; fi
echo "Result: $diffs difference(s)."; exit 1
