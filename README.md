# Jared Sloan

Index of my active repos. The table below is regenerated automatically once a week (and on demand) by [`scripts/generate-index.sh`](scripts/generate-index.sh) via [`.github/workflows/update-index.yml`](.github/workflows/update-index.yml) — new repos show up here on their own, nothing to maintain by hand. Repos created before 2020 (old legacy/practice repos) are excluded by a fixed cutoff date in the script, not a maintained name list.

<details>
<summary>One-time setup (already done locally, needed once for the automation to run in CI)</summary>

The workflow needs to list *private* repos across the whole account, which the default per-repo `GITHUB_TOKEN` can't do (it's scoped to just this repo). It needs a token with read access to repo metadata for the whole account, stored as a repo secret named `INDEX_PAT`:

1. Create a fine-grained personal access token at github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens. Resource owner: `jaredpsloan`. Repository access: All repositories. Permissions: Repository → Metadata → Read-only (that's the only permission needed).
2. Add it as a secret on this repo: `gh secret set INDEX_PAT` (paste the token when prompted), or via Settings → Secrets and variables → Actions on github.com.

Without this secret, the scheduled workflow runs but the listing step will fail (or silently only see this one repo). `scripts/generate-index.sh` works fine locally against `gh auth login`'s own token in the meantime — this secret is only needed for the unattended weekly run.

</details>

<!-- REPO-INDEX:START -->
| Repo | Description | Visibility |
| --- | --- | --- |

_Last updated: 2026-08-10T02:16:14Z_
<!-- REPO-INDEX:END -->
