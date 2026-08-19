# Resume: jaredsloan.com AWS deployment

Temporary file — delete once jaredsloan.com is confirmed live and this is
no longer needed. Full context in [website/README.md](website/README.md).

## Status (2026-08-19, Windows session): fully deployed, waiting on propagation

Nameservers were switched at Namecheap and propagated;
`01-aws-website-setup.ps1` went through the remaining steps in two passes
(one to request the cert + add its DNS validation record, one — after the
cert issued — to create CloudFront and the alias records):

- S3 bucket `jaredsloan.com` — content uploaded
- ACM cert (us-east-1) — issued
- Route53 hosted zone `Z095498413M731DYI0X8S` — existing MX/SPF/site-verification
  TXT records mirrored in before cutover
- CloudFront distribution `E3TBVF9N2U631X` (`ddtnm9unbxcxc.cloudfront.net`) — created
- Apex + `www` ALIAS records — created

**Nothing left to do except wait.** CloudFront distributions take
10-20 minutes to fully deploy after creation, plus normal DNS propagation.
Check `https://jaredsloan.com` directly, or:
```
aws cloudfront get-distribution --id E3TBVF9N2U631X --query Distribution.Status --output text
```
Once that says `Deployed` and the site loads, this file (and the GitHub
Pages interim deploy, once this is confirmed as the permanent home) can be
retired.

## Easy resume prompt

If something looks broken when you check, paste this back:

> Check on the jaredsloan.com AWS deploy from RESUME.md in jaredpsloan —
> CloudFront distribution E3TBVF9N2U631X. Site isn't loading right, figure
> out why and fix it.
