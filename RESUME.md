# Resume: jaredsloan.com AWS deployment + Pages toggle

Temporary file — delete once jaredsloan.com is live on AWS and this is no
longer needed. Full context in [website/README.md](website/README.md).

## What's done

- `website/index.html` — complete, self-contained site. Built and
  previewed live before committing.
- `website/01-aws-website-setup.ps1` — idempotent setup script for
  S3 + CloudFront + ACM + Route53. Written, **not run** — this session
  (a Mac) has no `aws`/`az`/`gcloud` CLI installed at all (confirmed
  directly, not assumed), and no credential material for any of the
  three cloud accounts exists here regardless — that only lives on the
  Windows machine per
  [mineral-saga/infrastructure/local-cli-access.md](https://github.com/jaredpsloan/mineral-saga/blob/main/infrastructure/local-cli-access.md).
- `.github/workflows/deploy-pages.yml` — free GitHub Pages interim
  deploy, no cloud credentials needed at all. Pushed, but needs one
  manual repo-settings toggle (below) before it actually takes effect.

## Two separate small things left, different urgency

1. **Quick (30 seconds), unblocks something live today:** Settings →
   Pages → Build and deployment → Source: **"GitHub Actions"** in this
   repo's web UI. Not doable via `git push` or any workflow file — it's a
   repository-settings change only a human with repo admin access (in a
   browser) can make. After this, pushes to `website/index.html` deploy
   automatically to `https://jaredpsloan.github.io/jaredpsloan/`.

2. **The actual goal (~10-15 min including DNS propagation waits):** run
   `website/01-aws-website-setup.ps1` from the Windows machine. It's
   designed to be re-run 2-3 times across the DNS delay — each run picks
   up wherever the last one left off, per its own printed status. Exact
   sequence and prereqs are in the script's header and
   [website/README.md](website/README.md).

## Also pending (different repo, same underlying blocker)

[mineral-saga](https://github.com/jaredpsloan/mineral-saga)'s three cloud
status dashboards have the identical "written but not run, needs the
Windows machine" status — see that repo's own `RESUME.md` for its
specific setup scripts and resume prompt. Worth doing both Windows-side
sessions back to back since they're the same kind of task.

## Easy resume prompt

Paste this back whenever ready to continue:

> Resume the jaredsloan.com AWS deployment from RESUME.md in jaredpsloan.
> I've [toggled GitHub Pages source to Actions / run
> 01-aws-website-setup.ps1 and it printed: ...]. Check what's live and
> fix whatever's broken.
