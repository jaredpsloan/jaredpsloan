# jaredsloan.com

**Status: built, not yet deployed.** `index.html` is a complete,
self-contained static site (fonts inlined, no external requests, no
build step) — ready to host. Not live yet because deploying it needs a
working AWS CLI credential, which this session didn't have (see
`01-aws-website-setup.ps1`'s header for why).

## What it is

A single-page personal/professional site, built from public LinkedIn
profile research and the Career section in the main
[README.md](../README.md): role, background (SQL Server DBA in healthcare
→ multi-cloud data platform engineering), stack, certification path
(DP-300 in progress, DP-700 planned next), and real evidence from this
account's own infrastructure work (multi-cloud OIDC, cost governance,
applied AI pipelines) rather than just a title list.

**No profile photo** — LinkedIn blocks headshot image URLs from
unauthenticated page fetches (confirmed directly: the page's HTML exposes
a cover/background image URL but not the profile photo itself). Built
without one rather than faking a placeholder photo; drop a real image into
this folder and reference it in `index.html` whenever there's one to use.

**Design:** deliberately grounded in the actual subject matter — laid out
like a schema/systems-status document (a "record" block, labeled data
tables, a terminal-style status bar) rather than a generic gradient-hero
portfolio template, since the subject is a database/platform engineer, not
a designer or marketer. JetBrains Mono for headings/data, IBM Plex Sans
for body copy, both embedded as base64 `@font-face` data — no external
font requests, works completely offline once loaded.

## Why AWS

Asked "would AWS have a good option for hosting a basic professional
site" — yes: **S3 (storage) + CloudFront (CDN/HTTPS) + ACM (free TLS
cert) + Route53 (DNS)** is the standard, cheap, professional-grade pattern
for exactly this — a handful of cents a month at this traffic level
(mostly the ~$0.50/month Route53 hosted zone; S3 storage and CloudFront's
free tier cover the rest). Same reasoning as
[mineral-saga](https://github.com/jaredpsloan/mineral-saga)'s dashboard
work: cheapest genuinely-good-practice option on the cloud already being
prioritized for hands-on learning.

**One real requirement worth knowing up front:** CloudFront's apex-domain
(`jaredsloan.com`, not `www.jaredsloan.com`) support needs a Route53 ALIAS
record specifically — Namecheap's own DNS can't do that for a domain
pointed at CloudFront. The setup script below delegates DNS to Route53
(nameserver change at Namecheap, one manual step, otherwise everything
else is scripted) rather than trying to make Namecheap's DNS do something
it structurally can't.

## To deploy

Run from a machine with a working AWS CLI credential
(`01-aws-website-setup.ps1`'s header has the exact prereqs). It's
idempotent and designed to be re-run as it progresses through: bucket →
ACM cert request → Route53 hosted zone (prints nameservers — **update
these at Namecheap, this is the one manual step**) → ACM DNS validation →
CloudFront distribution → bucket policy (CloudFront-only read access, kept
private otherwise) → apex + www ALIAS records.

```powershell
cd website
./01-aws-website-setup.ps1
```

Expect to run it 2-3 times across the DNS propagation delay (nameserver
change → ACM validation → cert issues → CloudFront creation) — each run
picks up wherever the last one left off, per its own printed status.

## To update content later

```
aws s3 cp index.html s3://jaredsloan.com/index.html --content-type text/html
aws cloudfront create-invalidation --distribution-id <ID> --paths '/*'
```
(exact command also printed at the end of a successful setup run)
