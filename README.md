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
| [house-real-estate-investing](https://github.com/jaredpsloan/house-real-estate-investing) | Real estate research: current home analysis and relocation market comparison. | Private |
| [mineral-saga](https://github.com/jaredpsloan/mineral-saga) | Mineral Saga business: brand site, eBay store, mineral-ID app, and multi-cloud identity-federation reference. | Private |
| [packetpupper](https://github.com/jaredpsloan/packetpupper) | Music project growth plan and tech career strategy guides. | Private |
| [retro-games](https://github.com/jaredpsloan/retro-games) | Placeholder for a future retro games project. | Private |
| [rodtheprod](https://github.com/jaredpsloan/rodtheprod) | 2d platform and chrono trigger style mix up game | Private |
| [sticker-business](https://github.com/jaredpsloan/sticker-business) | Business plan for a niche e-commerce sticker operation (Etsy/eBay). | Private |
| [wizard-crystal-game](https://github.com/jaredpsloan/wizard-crystal-game) | Premium single-player fantasy card game — business plan, dev strategy, and lore guides. | Private |

_Last updated: 2026-08-10T02:15:28Z_
<!-- REPO-INDEX:END -->
