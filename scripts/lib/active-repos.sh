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
