#!/usr/bin/env bash
# Regenerates the repo table in README.md between the REPO-INDEX markers.
# Reads GH_TOKEN/GITHUB_TOKEN from the environment (gh CLI picks it up
# automatically) - needs a token that can list this account's private repos,
# not just the default per-repo Actions token.
set -euo pipefail

cd "$(dirname "$0")/.."

SELF_NAME="jaredpsloan"
START_MARK="<!-- REPO-INDEX:START -->"
END_MARK="<!-- REPO-INDEX:END -->"

table=$(gh api user/repos -X GET -f type=owner -f per_page=100 --paginate \
  --jq '.[] | select(.fork == false) | [.name, (.description // ""), (if .private then "Private" else "Public" end), .html_url] | @tsv' \
  | sort -f -t $'\t' -k1,1 \
  | awk -F'\t' -v self="$SELF_NAME" '
      BEGIN { print "| Repo | Description | Visibility |"; print "| --- | --- | --- |" }
      $1 != self { printf "| [%s](%s) | %s | %s |\n", $1, $4, $2, $3 }
    ')

generated_line="_Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"

awk -v start="$START_MARK" -v end="$END_MARK" -v table="$table" -v stamp="$generated_line" '
  $0 == start { print; print table; print ""; print stamp; skipping = 1; next }
  $0 == end   { skipping = 0 }
  !skipping   { print }
' README.md > README.md.tmp && mv README.md.tmp README.md
