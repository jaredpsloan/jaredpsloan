<#
  Deploys website/index.html as jaredsloan.com on AWS: S3 (static content),
  CloudFront (HTTPS + CDN), ACM (free TLS cert), and a Route53 hosted zone
  to host DNS for the domain (registered at Namecheap, DNS delegated here
  -- CloudFront's apex-domain ALIAS record support requires Route53
  specifically; Namecheap's own DNS can't ALIAS an apex domain to a
  CloudFront distribution).

  Not run yet as of this writing -- needs a working AWS CLI credential.
  Written PowerShell-first to match this account's other repos
  (mineral-saga's infrastructure/ scripts), even though this one has no
  GitHub Actions/OIDC component -- it's a one-time personal deploy, not a
  CI workflow, so a stored local credential (already set up per
  mineral-saga's infrastructure/local-cli-access.md) is the right tool
  here, not OIDC.

  Prereqs:
    - AWS CLI installed and logged in (a profile with enough permissions
      to create S3 buckets, CloudFront distributions, ACM certificates,
      and Route53 hosted zones -- AdministratorAccess is simplest).
    - Domain jaredsloan.com already registered at Namecheap.
    - ACM certificate for CloudFront MUST be requested in us-east-1,
      regardless of which region the bucket lives in -- CloudFront only
      reads certs from that region. Easy to get this wrong once and
      silently have a distribution that never validates.

  Idempotent where practical, same conventions as mineral-saga's
  01-*-setup.ps1 scripts.
#>

# ------------------------- FILL THESE IN -------------------------
$Domain            = "jaredsloan.com"
$AwsProfile        = "default"
$BucketRegion      = "us-east-1"   # bucket region can differ from us-east-1 in general,
                                    # but keeping it the same avoids any doubt --
                                    # the ACM cert MUST be us-east-1 regardless.
$BucketName        = $Domain       # S3 bucket names matching the domain are
                                    # conventional for static-site hosting, not required
# -----------------------------------------------------------------

$ErrorActionPreference = "Stop"
$aws = "aws"

function Invoke-Aws {
    param([string[]]$CliArgs, [switch]$AllowFailure, [string]$Region = $null)
    $regionArgs = if ($Region) { @("--region", $Region) } else { @() }
    $out = & $aws @CliArgs @regionArgs --profile $AwsProfile
    if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) {
        throw "aws $($CliArgs -join ' ') failed with exit code $LASTEXITCODE"
    }
    return $out
}

# ---------- 1. S3 bucket (private -- CloudFront reads via Origin Access Control, not public bucket policy) ----------
Write-Host "==> Ensuring bucket $BucketName"
$existingBucket = Invoke-Aws @("s3api", "head-bucket", "--bucket", $BucketName) -AllowFailure
if ($LASTEXITCODE -ne 0) {
    if ($BucketRegion -eq "us-east-1") {
        Invoke-Aws @("s3api", "create-bucket", "--bucket", $BucketName) | Out-Null
    } else {
        Invoke-Aws @("s3api", "create-bucket", "--bucket", $BucketName, "--region", $BucketRegion,
            "--create-bucket-configuration", "LocationConstraint=$BucketRegion") | Out-Null
    }
    Write-Host "    created"
} else {
    Write-Host "    already exists"
}

Write-Host "==> Blocking all public access (CloudFront reads privately via OAC, no public bucket needed)"
Invoke-Aws @("s3api", "put-public-access-block", "--bucket", $BucketName,
    "--public-access-block-configuration", "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true") | Out-Null

Write-Host "==> Uploading site content"
Invoke-Aws @("s3", "cp", "index.html", "s3://$BucketName/index.html", "--content-type", "text/html") | Out-Null

# ---------- 2. ACM certificate (MUST be us-east-1 for CloudFront) ----------
Write-Host "==> Requesting ACM certificate for $Domain (us-east-1, required for CloudFront)"
$existingCert = Invoke-Aws @("acm", "list-certificates", "--query",
    "CertificateSummaryList[?DomainName=='$Domain'].CertificateArn", "--output", "text") -Region "us-east-1" -AllowFailure
if ([string]::IsNullOrWhiteSpace($existingCert)) {
    $CertArn = Invoke-Aws @("acm", "request-certificate",
        "--domain-name", $Domain,
        "--subject-alternative-names", "www.$Domain",
        "--validation-method", "DNS",
        "--query", "CertificateArn", "--output", "text") -Region "us-east-1"
    Write-Host "    requested $CertArn -- DNS validation records needed before this issues (see step 4)"
} else {
    $CertArn = $existingCert
    Write-Host "    already exists: $CertArn"
}

# ---------- 3. Route53 hosted zone ----------
Write-Host "==> Ensuring Route53 hosted zone for $Domain"
$existingZone = Invoke-Aws @("route53", "list-hosted-zones-by-name", "--dns-name", $Domain,
    "--query", "HostedZones[?Name=='$Domain.'].Id", "--output", "text") -AllowFailure
if ([string]::IsNullOrWhiteSpace($existingZone)) {
    $zoneResult = Invoke-Aws @("route53", "create-hosted-zone", "--name", $Domain,
        "--caller-reference", (Get-Date -Format "yyyyMMddHHmmss")) | ConvertFrom-Json
    $ZoneId = $zoneResult.HostedZone.Id
    Write-Host "    created $ZoneId"
} else {
    $ZoneId = $existingZone
    Write-Host "    already exists: $ZoneId"
}

$nameServers = Invoke-Aws @("route53", "get-hosted-zone", "--id", $ZoneId, "--query", "DelegationSet.NameServers", "--output", "text")

Write-Host ""
Write-Host "================ MANUAL STEP REQUIRED ================"
Write-Host "At Namecheap (Domain List -> jaredsloan.com -> Nameservers -> Custom DNS),"
Write-Host "set these nameservers (replacing Namecheap's defaults):"
Write-Host $nameServers
Write-Host "DNS propagation can take up to 48h, though it's often much faster."
Write-Host "========================================================"
Write-Host ""
Write-Host "Once nameservers have propagated (verify with: nslookup -type=NS $Domain),"
Write-Host "re-run this script -- it will pick up from here idempotently, add the ACM"
Write-Host "DNS validation record, wait for the cert to issue, then create the"
Write-Host "CloudFront distribution and the apex + www ALIAS records."
Write-Host ""
Write-Host "If the cert already shows ISSUED (check: aws acm describe-certificate"
Write-Host "--certificate-arn $CertArn --region us-east-1 --query Certificate.Status),"
Write-Host "the CloudFront + ALIAS record steps below will run on this same pass."

# ---------- 4. ACM DNS validation (only proceeds once the zone above is live) ----------
$certStatus = Invoke-Aws @("acm", "describe-certificate", "--certificate-arn", $CertArn,
    "--query", "Certificate.Status", "--output", "text") -Region "us-east-1" -AllowFailure

if ($certStatus -eq "PENDING_VALIDATION") {
    Write-Host "==> Adding ACM DNS validation record to Route53"
    $certDetail = Invoke-Aws @("acm", "describe-certificate", "--certificate-arn", $CertArn) -Region "us-east-1" | ConvertFrom-Json
    foreach ($v in $certDetail.Certificate.DomainValidationOptions) {
        $record = $v.ResourceRecord
        $changeBatch = @{
            Changes = @(@{
                Action = "UPSERT"
                ResourceRecordSet = @{
                    Name = $record.Name
                    Type = $record.Type
                    TTL = 300
                    ResourceRecords = @(@{ Value = $record.Value })
                }
            })
        } | ConvertTo-Json -Depth 6
        $changeBatchPath = Join-Path $env:TEMP "acm-validation-$Domain.json"
        [System.IO.File]::WriteAllText($changeBatchPath, $changeBatch, (New-Object System.Text.UTF8Encoding $false))
        Invoke-Aws @("route53", "change-resource-record-sets", "--hosted-zone-id", $ZoneId,
            "--change-batch", "file://$changeBatchPath") | Out-Null
        Remove-Item $changeBatchPath -Force -ErrorAction SilentlyContinue
    }
    Write-Host "    validation record added -- cert typically issues within a few minutes, re-run to continue"
    exit 0
} elseif ($certStatus -ne "ISSUED") {
    Write-Host "==> Certificate status: $certStatus -- not ready yet, re-run later"
    exit 0
}

Write-Host "==> Certificate is ISSUED -- proceeding to CloudFront"

# ---------- 5. CloudFront distribution with Origin Access Control ----------
Write-Host "==> Ensuring Origin Access Control"
$oacList = Invoke-Aws @("cloudfront", "list-origin-access-controls",
    "--query", "OriginAccessControlList.Items[?Name=='$BucketName-oac'].Id", "--output", "text") -AllowFailure
if ([string]::IsNullOrWhiteSpace($oacList)) {
    $oacConfig = @{
        Name = "$BucketName-oac"
        OriginAccessControlOriginType = "s3"
        SigningBehavior = "always"
        SigningProtocol = "sigv4"
    } | ConvertTo-Json
    $oacPath = Join-Path $env:TEMP "oac-$BucketName.json"
    [System.IO.File]::WriteAllText($oacPath, $oacConfig, (New-Object System.Text.UTF8Encoding $false))
    $OacId = (Invoke-Aws @("cloudfront", "create-origin-access-control", "--origin-access-control-config", "file://$oacPath") | ConvertFrom-Json).OriginAccessControl.Id
    Remove-Item $oacPath -Force -ErrorAction SilentlyContinue
    Write-Host "    created $OacId"
} else {
    $OacId = $oacList
    Write-Host "    already exists: $OacId"
}

Write-Host "==> Checking for existing CloudFront distribution"
$existingDist = Invoke-Aws @("cloudfront", "list-distributions",
    "--query", "DistributionList.Items[?Aliases.Items[0]=='$Domain'].Id", "--output", "text") -AllowFailure

if ([string]::IsNullOrWhiteSpace($existingDist)) {
    Write-Host "==> Creating CloudFront distribution"
    $distConfig = @{
        CallerReference = (Get-Date -Format "yyyyMMddHHmmss")
        Aliases = @{ Quantity = 2; Items = @($Domain, "www.$Domain") }
        DefaultRootObject = "index.html"
        Origins = @{
            Quantity = 1
            Items = @(@{
                Id = "s3-$BucketName"
                DomainName = "$BucketName.s3.$BucketRegion.amazonaws.com"
                OriginAccessControlId = $OacId
                S3OriginConfig = @{ OriginAccessIdentity = "" }
            })
        }
        DefaultCacheBehavior = @{
            TargetOriginId = "s3-$BucketName"
            ViewerProtocolPolicy = "redirect-to-https"
            AllowedMethods = @{ Quantity = 2; Items = @("GET", "HEAD") }
            ForwardedValues = @{ QueryString = $false; Cookies = @{ Forward = "none" } }
            MinTTL = 300
            DefaultTTL = 86400
        }
        ViewerCertificate = @{
            ACMCertificateArn = $CertArn
            SSLSupportMethod = "sni-only"
            MinimumProtocolVersion = "TLSv1.2_2021"
        }
        Enabled = $true
        Comment = "jaredsloan.com personal site"
    } | ConvertTo-Json -Depth 10
    $distPath = Join-Path $env:TEMP "cf-dist-$Domain.json"
    [System.IO.File]::WriteAllText($distPath, $distConfig, (New-Object System.Text.UTF8Encoding $false))
    $distResult = Invoke-Aws @("cloudfront", "create-distribution", "--distribution-config", "file://$distPath") | ConvertFrom-Json
    Remove-Item $distPath -Force -ErrorAction SilentlyContinue
    $DistId = $distResult.Distribution.Id
    $DistDomain = $distResult.Distribution.DomainName
    Write-Host "    created $DistId ($DistDomain) -- takes 10-20 min to fully deploy"
} else {
    $DistId = $existingDist
    $DistDomain = Invoke-Aws @("cloudfront", "get-distribution", "--id", $DistId, "--query", "Distribution.DomainName", "--output", "text")
    Write-Host "    already exists: $DistId ($DistDomain)"
}

Write-Host "==> Granting CloudFront (via OAC) read access to the bucket -- bucket stays otherwise private"
$accountId = Invoke-Aws @("sts", "get-caller-identity", "--query", "Account", "--output", "text")
$bucketPolicy = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BucketName/*",
      "Condition": {
        "StringEquals": { "AWS:SourceArn": "arn:aws:cloudfront::${accountId}:distribution/$DistId" }
      }
    }
  ]
}
"@
$bucketPolicyPath = Join-Path $env:TEMP "bucket-policy-$BucketName.json"
[System.IO.File]::WriteAllText($bucketPolicyPath, $bucketPolicy, (New-Object System.Text.UTF8Encoding $false))
Invoke-Aws @("s3api", "put-bucket-policy", "--bucket", $BucketName, "--policy", "file://$bucketPolicyPath") | Out-Null
Remove-Item $bucketPolicyPath -Force -ErrorAction SilentlyContinue

# ---------- 6. Route53 ALIAS records: apex + www -> CloudFront ----------
# CloudFront's hosted zone ID is the same fixed value for every distribution,
# not account/region-specific -- this is the documented constant, not
# something to look up per-distribution.
$CloudFrontHostedZoneId = "Z2FDTNDATAQYW2"
Write-Host "==> Creating apex + www ALIAS records -> CloudFront"
$aliasChangeBatch = @{
    Changes = @(
        @{ Action = "UPSERT"; ResourceRecordSet = @{ Name = $Domain; Type = "A"; AliasTarget = @{ HostedZoneId = $CloudFrontHostedZoneId; DNSName = $DistDomain; EvaluateTargetHealth = $false } } },
        @{ Action = "UPSERT"; ResourceRecordSet = @{ Name = "www.$Domain"; Type = "A"; AliasTarget = @{ HostedZoneId = $CloudFrontHostedZoneId; DNSName = $DistDomain; EvaluateTargetHealth = $false } } }
    )
} | ConvertTo-Json -Depth 8
$aliasPath = Join-Path $env:TEMP "alias-$Domain.json"
[System.IO.File]::WriteAllText($aliasPath, $aliasChangeBatch, (New-Object System.Text.UTF8Encoding $false))
Invoke-Aws @("route53", "change-resource-record-sets", "--hosted-zone-id", $ZoneId, "--change-batch", "file://$aliasPath") | Out-Null
Remove-Item $aliasPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================ DONE ================"
Write-Host "https://$Domain (and https://www.$Domain) should resolve once CloudFront"
Write-Host "finishes deploying (10-20 min after creation) and DNS propagates."
Write-Host "======================================="
Write-Host ""
Write-Host "To update the site after editing website/index.html, just re-run:"
Write-Host "  aws s3 cp index.html s3://$BucketName/index.html --content-type text/html --profile $AwsProfile"
Write-Host "  aws cloudfront create-invalidation --distribution-id $DistId --paths '/*' --profile $AwsProfile"
