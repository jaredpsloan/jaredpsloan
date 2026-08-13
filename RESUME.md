# Resume: jaredsloan.com AWS deployment + Pages toggle

Temporary file — delete once jaredsloan.com is live on AWS and this is no
longer needed. Full context in [website/README.md](website/README.md).

## What's done (2026-08-12, Windows session)

- `website/index.html` — complete, self-contained site.
- GitHub Pages toggled to Actions source (via `gh api`) and the deploy
  workflow run — **live now** at
  https://jaredpsloan.github.io/jaredpsloan/.
- `website/01-aws-website-setup.ps1` — run once from the Windows machine
  (credentials live there per
  [mineral-saga/infrastructure/local-cli-access.md](https://github.com/jaredpsloan/mineral-saga/blob/main/infrastructure/local-cli-access.md),
  now also syncable to other machines via
  [mineral-saga/infrastructure/bitwarden/](https://github.com/jaredpsloan/mineral-saga/tree/main/infrastructure/bitwarden)).
  Created: S3 bucket (content uploaded), ACM certificate request (us-east-1,
  pending DNS validation), Route53 hosted zone. Also manually mirrored the
  domain's existing MX + SPF + Google-site-verification TXT records into
  the new Route53 zone first, so switching nameservers won't break existing
  email forwarding.

## One thing left, blocked on a human/manual step

**At Namecheap** (Domain List → jaredsloan.com → Nameservers → Custom DNS),
set these nameservers (replacing Namecheap's defaults):
```
ns-1739.awsdns-25.co.uk
ns-1415.awsdns-48.org
ns-204.awsdns-25.com
ns-675.awsdns-20.net
```
Not doable via any script or API call available here — needs your Namecheap
login. DNS propagation can take up to 48h, though often much faster
(verify with `nslookup -type=NS jaredsloan.com`).

Once propagated, re-run `website/01-aws-website-setup.ps1` — idempotent,
picks up from here: adds the ACM DNS validation record, waits for the cert
to issue, creates the CloudFront distribution, and adds the apex + www
ALIAS records. May need 2-3 re-runs across the DNS/cert delay.

## Easy resume prompt

Paste this back whenever ready to continue:

> Resume the jaredsloan.com AWS deployment from RESUME.md in jaredpsloan.
> I've set the Namecheap nameservers [and it's been X hours/days]. Re-run
> 01-aws-website-setup.ps1, check what's live, and fix whatever's broken.
