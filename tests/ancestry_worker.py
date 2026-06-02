"""
taxonomy_worker.py
------------------
This file must live in the same folder as your notebook.
It defines the worker functions so that Python's multiprocessing
can find them when it spawns new processes.
"""

import re

# Matches a trailing .*? (optionally preceded by \| which is part of the
# lookahead anchor) so we can strip it before measuring match depth.
_TRAILING_WILDCARD = re.compile(r'(?:\\[|])?\\.\*\??$')


def _strip_trailing_wildcard(pattern_str):
    """
    Remove a trailing .*? (and an optional preceding \| anchor) from a raw
    pattern string so we can measure how far into the taxonomy string the
    meaningful part of the rule reaches.

    Examples
    --------
    '.*?\\|Odonata\\|.*?'                        -> '.*?\\|Odonata\\|'
    '.*?\\|Hexapoda\\|(.*?\\|)?Pterygota\\|.*?'  -> '.*?\\|Hexapoda\\|(.*?\\|)?Pterygota\\|'
    '.*?\\|Insecta\\|'                            -> '.*?\\|Insecta\\|'   (no change)
    """
    return _TRAILING_WILDCARD.sub('', pattern_str)


def _init_worker(rules_data):
    """
    Called once per worker process at startup.

    Builds two compiled-pattern lists from the raw (label, pattern_str) pairs:
      COMPILED_RULES        – full patterns used to test whether a rule matches
      COMPILED_RULES_DEPTH  – patterns with the trailing .*? stripped, used to
                              measure how far into the string the match reaches
    """
    global COMPILED_RULES, COMPILED_RULES_DEPTH
    COMPILED_RULES = []
    COMPILED_RULES_DEPTH = []
    for label, pattern_str in rules_data:
        COMPILED_RULES.append((label, re.compile(pattern_str)))
        depth_str = _strip_trailing_wildcard(pattern_str)
        COMPILED_RULES_DEPTH.append((label, re.compile(depth_str)))


def process_chunk(lines):
    """
    Takes a list of taxonomy strings, matches each against all rules, and
    returns a tuple of two parallel lists of result strings:

      primary_results     – one row per input line; second column holds the
                            single best (most-distal) label, or blank if none
      multimatch_results  – same rows but only for lines that had 2+ matches;
                            second column holds all matching labels joined by '; '
    """
    primary_results   = []
    multimatch_results = []

    for taxonomy_string in lines:
        taxonomy_string = taxonomy_string.rstrip("\n")
        if not taxonomy_string:
            continue

        # --- find all matching labels (preserving first-seen order) ----------
        seen   = set()
        labels = []          # unique matching labels in rule order
        depths = {}          # label -> end position of the depth pattern match

        for (label, full_pat), (_, depth_pat) in zip(COMPILED_RULES, COMPILED_RULES_DEPTH):
            if full_pat.match(taxonomy_string):
                if label not in seen:
                    seen.add(label)
                    labels.append(label)
                    # measure how far into the string the meaningful part goes
                    m = depth_pat.search(taxonomy_string)
                    depths[label] = m.end() if m else 0

        # --- choose the best label -------------------------------------------
        if labels:
            best_label = max(labels, key=lambda lbl: depths[lbl])
        else:
            best_label = ""

        primary_results.append(f"{taxonomy_string}\t{best_label}\n")

        # --- record multi-match rows separately ------------------------------
        if len(labels) >= 2:
            all_labels = "; ".join(labels)
            multimatch_results.append(f"{taxonomy_string}\t{all_labels}\n")

    return primary_results, multimatch_results
