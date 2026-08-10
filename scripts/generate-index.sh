#!/usr/bin/env bash
# Regenerates the repo table in README.md between the REPO-INDEX markers.
# Reads GH_TOKEN/GITHUB_TOKEN from the environment (gh CLI picks it up
# automatically) - needs a token that can list this account's private repos,
# not just the default per-repo Actions token.
set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/lib/active-repos.sh

SELF_NAME="jaredpsloan"
START_MARK="<!-- REPO-INDEX:START -->"
END_MARK="<!-- REPO-INDEX:END -->"

rows_tsv=$(active_repos_tsv | sort -f -t $'\t' -k1,1)

if [ -z "$rows_tsv" ]; then
  # A transient empty/erroring API response should never wipe out a
  # previously-good table - fail loudly instead (bit us once already).
  echo "No active repos returned by the GitHub API - aborting without touching README.md" >&2
  exit 1
fi

table="| Repo | Status | Description | Visibility |
| --- | --- | --- | --- |"
while IFS=$'\t' read -r name description visibility url; do
  [ "$name" = "$SELF_NAME" ] && continue
  status=$(repo_status "$name")
  table="$table
| [$name]($url) | $status | $description | $visibility |"
done <<< "$rows_tsv"

generated_line="_Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"

awk -v start="$START_MARK" -v end="$END_MARK" -v table="$table" -v stamp="$generated_line" '
  $0 == start { print; print table; print ""; print stamp; skipping = 1; next }
  $0 == end   { skipping = 0 }
  !skipping   { print }
' README.md > README.md.tmp && mv README.md.tmp README.md
