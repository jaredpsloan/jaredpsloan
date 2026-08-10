#!/usr/bin/env bash
# Regenerates ../all-repos.code-workspace (one level above this repo, i.e.
# the GitHub root) from the same active-repo set as generate-index.sh:
# non-fork, created on/after ACTIVE_REPOS_CUTOFF - intersected with whatever
# repos are actually cloned locally, since a workspace entry needs a real
# folder to point at.
#
# This is meant to be run locally (or via `gh auth login`'s token), not in
# CI - the GitHub Actions runner has no visibility into which repos are
# cloned on this machine, so only generate-index.sh runs there.
set -euo pipefail

cd "$(dirname "$0")/.."
source scripts/lib/active-repos.sh

GITHUB_ROOT="$(cd .. && pwd)"
WORKSPACE_FILE="$GITHUB_ROOT/all-repos.code-workspace"

mapfile -t names < <(active_repos_tsv | awk -F'\t' '{print $1}' | sort -f)

folders=()
for name in "${names[@]}"; do
  if [ -d "$GITHUB_ROOT/$name/.git" ]; then
    folders+=("$name")
  fi
done

if [ ${#folders[@]} -eq 0 ]; then
  echo "No matching local repos found under $GITHUB_ROOT - aborting without touching $WORKSPACE_FILE" >&2
  exit 1
fi

{
  echo '{'
  echo $'\t"folders": ['
  for i in "${!folders[@]}"; do
    comma=","
    [ "$i" -eq $((${#folders[@]} - 1)) ] && comma=""
    printf '\t\t{ "path": "%s" }%s\n' "${folders[$i]}" "$comma"
  done
  echo $'\t],'
  echo $'\t"settings": {}'
  echo '}'
} > "$WORKSPACE_FILE.tmp"
mv "$WORKSPACE_FILE.tmp" "$WORKSPACE_FILE"

echo "Wrote $WORKSPACE_FILE with ${#folders[@]} folder(s): ${folders[*]}"
