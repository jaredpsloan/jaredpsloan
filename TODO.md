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

- [ ] **Confirm the sticker-business Reddit secrets are actually set.** The
      daily meme-sticker pipeline (`daily-meme-stickers.yml`, 8am ET) is
      merged and scheduled, but it silently fails until `REDDIT_CLIENT_ID`
      and `REDDIT_CLIENT_SECRET` exist as repo secrets. Check
      <https://github.com/jaredpsloan/sticker-business/settings/secrets/actions>;
      if missing, get them from <https://www.reddit.com/prefs/apps> (create
      app → type `script`) and add via the GitHub UI or
      `scripts/admin/setup_github_secrets.py --trigger-test-run`. Detail:
      [sticker-business/guides/meme-sticker-pipeline.md](https://github.com/jaredpsloan/sticker-business/blob/main/guides/meme-sticker-pipeline.md).

## Done

*(move items here with the date resolved, instead of deleting — keeps a
record of what was actually blocking at the time)*
