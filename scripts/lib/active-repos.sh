# Shared repo-listing logic for generate-index.sh and generate-workspace.sh.
# Keeping the cutoff and query in one place means the README index and the
# VS Code workspace can't drift out of sync on what counts as "active".
ACTIVE_REPOS_CUTOFF="2020-01-01T00:00:00Z"

# Prints one TSV row per active (non-fork, created on/after cutoff) owned
# repo: name, description, visibility, html_url
active_repos_tsv() {
  # gh api's --jq takes one pre-built expression - it doesn't support jq's
  # own --arg, so the cutoff has to be interpolated into the filter string.
  gh api user/repos -X GET -f type=owner -f per_page=100 --paginate \
    --jq ".[] | select(.fork == false) | select(.created_at >= \"$ACTIVE_REPOS_CUTOFF\") | [.name, (.description // \"\"), (if .private then \"Private\" else \"Public\" end), .html_url] | @tsv"
}

# Prints the short status tag from a repo's own "**Status:** ..." README
# line (the repo-context convention described in this repo's README), e.g.
# "docs-only" or "live". Falls back to "—" if the line is missing, or if
# the fetch fails - which happens if INDEX_PAT only has the Metadata:Read
# permission from the original setup and not Contents:Read (see README
# setup notes). Non-fatal either way, so one repo's fetch failure never
# breaks the rest of the table.
repo_status() {
  local name="$1"
  local line status
  line="$(gh api "repos/jaredpsloan/$name/readme" --jq '.content' 2>/dev/null \
    | tr -d '\n' | base64 -d 2>/dev/null \
    | grep -m1 '^\*\*Status:\*\*')" || true
  status="$(printf '%s' "$line" | sed -E 's/^\*\*Status:\*\* *//; s/ — .*$//')"
  if [ -n "$status" ]; then
    printf '%s' "$status"
  else
    printf '%s' "—"
  fi
}
