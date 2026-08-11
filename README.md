# Jared Sloan

## Career

Senior Data Platform Engineer at CVS Health (remote, New Haven, CT),
focused on building reliable, scalable data systems. Background: SQL
Server database administration in healthcare (HL7 data exchange, 24/7
production ownership, ETL/reporting via SSRS and SSIS) before moving into
multi-cloud data platform engineering — including cross-cloud database
engine evaluation work (e.g. Google Cloud AlloyDB) and applied,
production-oriented AI tooling.

MS from Central Connecticut State University, BS from University of
Massachusetts Lowell. SAFe Practitioner certified.

**Currently:** studying for the Azure Database Administrator Associate
(DP-300) — a direct extension of the SQL Server DBA background onto
Azure. **Planned next:** the Fabric Data Engineer Associate (DP-700),
Microsoft's current data-engineering credential (replacing the retired
DP-203) and the natural complement to DP-300 — administering *and*
building the platform, together a closer match to the actual job than
either cert alone.

The repos below are a mix of professional-adjacent infrastructure
practice (multi-cloud OIDC/Workload Identity Federation, cost governance,
applied AI pipelines — see [mineral-saga](https://github.com/jaredpsloan/mineral-saga)
for the most complete example) and personal projects.

## Repo index

Index of my active repos. The table below is regenerated automatically once a week (and on demand) by [`scripts/generate-index.sh`](scripts/generate-index.sh) via [`.github/workflows/update-index.yml`](.github/workflows/update-index.yml) — new repos show up here on their own, nothing to maintain by hand. Repos created before 2020 (old legacy/practice repos) are excluded by a fixed cutoff date in the script, not a maintained name list.

## Repo-context convention

Every active repo's README starts with a `**Status:** ...` line right under the title — `docs-only`, `in development`, `live`, or `empty`, plus a short clause. The Status column below is pulled straight from that line, so it's always the fast, at-a-glance signal for which repos are just planning docs versus real running code.

The full context for an agent picking up a repo cold — stack, how to run it, cloud/production access — lives *in that repo's own README*, not duplicated here (a second copy of that detail would just drift out of sync). For a repo with real infrastructure, see [mineral-saga](https://github.com/jaredpsloan/mineral-saga)'s README for the pattern: a live-channels list, a repo-layout table, and a conventions section. Docs-only repos just need the Status line — there's no stack or access story to document yet.

Point Claude (or yourself) at a repo by name and its README should be enough to get oriented without opening every file.

<details>
<summary>One-time setup (already done locally, needed once for the automation to run in CI)</summary>

The workflow needs to (a) list *private* repos across the whole account and (b) read each repo's README to pull its Status line — neither of which the default per-repo `GITHUB_TOKEN` can do (it's scoped to just this repo's contents). It needs a token with broader read access, stored as a repo secret named `INDEX_PAT`:

1. Create a fine-grained personal access token at github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens. Resource owner: `jaredpsloan`. Repository access: All repositories. Permissions: Repository → Metadata → Read-only, and Repository → Contents → Read-only (the second one is only needed for the Status column — without it the rest of the table still works, just with `—` in that column).
2. Add it as a secret on this repo: `gh secret set INDEX_PAT` (paste the token when prompted), or via Settings → Secrets and variables → Actions on github.com.

Without this secret, the scheduled workflow runs but the listing step will fail (or silently only see this one repo). `scripts/generate-index.sh` works fine locally against `gh auth login`'s own token in the meantime — this secret is only needed for the unattended weekly run.

</details>

<!-- REPO-INDEX:START -->
| Repo | Status | Description | Visibility |
| --- | --- | --- | --- |

_Last updated: 2026-08-10T14:18:08Z_
<!-- REPO-INDEX:END -->
