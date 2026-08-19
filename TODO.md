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

- [ ] **Reset the sticker-business `CLAUDE_CODE_OAUTH_TOKEN`.** The daily
      meme-sticker pipeline has been failing every scheduled run since
      2026-08-13 with `401 Invalid bearer token` on the "Sanity-check
      Claude Code CLI + auth" step — the token set 2026-08-11 has expired
      or been invalidated. Run `claude setup-token` locally, then
      `gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo jaredpsloan/sticker-business`
      (or `scripts/admin/setup_github_secrets.py --trigger-test-run` to also
      fire an immediate test run instead of waiting for tomorrow's 8am
      slot). Detail: [sticker-business/guides/meme-sticker-pipeline.md](https://github.com/jaredpsloan/sticker-business/blob/main/guides/meme-sticker-pipeline.md).

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
