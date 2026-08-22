# TODO

Cross-repo action list — things that need a human (not an agent) to actually
do them, pulled together from what's outstanding across
[mineral-saga](https://github.com/jaredpsloan/mineral-saga),
[sticker-business](https://github.com/jaredpsloan/sticker-business), and
this repo. Each repo's own README/RESUME is still the source of truth for
detail; this is just the one place to see what's open at a glance.

Update this file whenever an item here gets resolved or a new cross-repo
action item shows up — stale checkboxes are worse than no list.

## Open

- [ ] **Set the mineral-saga dashboard password.** All three cloud status
      dashboards (Azure/AWS/GCP) are live but fail-closed — none has a real
      password yet. Run
      `infrastructure/dashboards-auth/set-dashboard-password.ps1`
      interactively (never through an agent — it's written to never print
      the password), save the password in your own password manager, then
      verify all three actually load with `curl -u dashboard:<password>
      <url>` for each. Full detail: [mineral-saga/RESUME.md](https://github.com/jaredpsloan/mineral-saga/blob/main/RESUME.md).

- [ ] **Bootstrap Bitwarden-synced cloud creds on the Mac (or any other
      laptop).** `upload-to-bitwarden.ps1` has already pushed the AWS/GCP/
      Azure automation credentials into Bitwarden from this Windows machine.
      On the Mac: `brew install bitwarden-cli azure-cli awscli jq` + the
      Google Cloud SDK, clone `mineral-saga`, then run
      `infrastructure/bitwarden/bootstrap.sh` interactively. Verify with
      `az account show`, `gcloud auth list`, `aws sts get-caller-identity`.
      Details: [mineral-saga/infrastructure/bitwarden/README.md](https://github.com/jaredpsloan/mineral-saga/blob/main/infrastructure/bitwarden/README.md).

- [ ] **Two secrets got crossed — fix both.** On 2026-08-22, mid-fix for the
      two items below, the Claude Code OAuth token from `claude setup-token`
      got pasted into the wrong place: it landed in `jaredpsloan/jaredpsloan`'s
      `INDEX_PAT` (twice) instead of `sticker-business`'s
      `CLAUDE_CODE_OAUTH_TOKEN`. Net result: **both are still broken**, in
      complementary ways. That Claude token is also now burned (it passed
      through an agent's view via a screenshot) — don't reuse it, generate
      fresh.
      - **jaredpsloan `INDEX_PAT`** currently holds a Claude token, not a
        GitHub PAT — `gh` errors `Bad credentials (HTTP 401)` on every run
        of `update-index.yml`. Needs a real fine-grained GitHub PAT
        (Settings → Developer settings → Fine-grained tokens; Resource
        owner `jaredpsloan`; Repository access: **All repositories**;
        permissions: Metadata Read-only + Contents Read-only — regenerate
        fresh rather than trust the old one is still copyable). Then:
        `gh secret set INDEX_PAT --repo jaredpsloan/jaredpsloan`.
      - **sticker-business `CLAUDE_CODE_OAUTH_TOKEN`** is still the original
        stale value from 2026-08-11 — the daily meme-sticker pipeline has
        been failing every scheduled run since 2026-08-13 with `401 Invalid
        bearer token` on "Sanity-check Claude Code CLI + auth". Run
        `claude setup-token` locally (fresh — not the burned one above),
        then `gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo jaredpsloan/sticker-business`.
      - No `export` step needed for either — that's a bash builtin, doesn't
        exist in cmd.exe, and isn't actually required for the `gh secret
        set` flow anyway.
      - **Verify by actual output, not exit code** — both workflows have
        reported green while doing nothing/wrong before:
        `gh workflow run update-index.yml` then check the table between
        `<!-- REPO-INDEX:START -->`/`END` in `jaredpsloan/README.md` isn't
        empty; `gh workflow run daily-meme-stickers.yml` then
        `gh run view --log` and confirm no `401`.

## Done

- [x] **(2026-08-19) Sticker-business Reddit secrets.** Turned out to be a
      non-issue — trend discovery no longer uses Reddit at all. It was
      switched to scraping Know Your Meme's newest-entries page instead
      (no credential needed; Reddit's OAuth app registration wasn't worth
      the friction for one signal source). `REDDIT_CLIENT_ID`/
      `REDDIT_CLIENT_SECRET` are unused now — safe to delete from repo
      secrets whenever convenient.

*(move items here with the date resolved, instead of deleting — keeps a
record of what was actually blocking at the time)*
