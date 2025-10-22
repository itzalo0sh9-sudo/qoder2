param(
    [string]$EnvFile = ".env.prod"
)

Write-Host "Validating production prerequisites..."

if (-not (Test-Path $EnvFile)) {
    Write-Error "Missing $EnvFile in repository root. Create it from .env.prod.example and set production secrets."
    exit 2
}

# Check certs
$certDir = "infrastructure/docker/nginx/certs"
if (-not (Test-Path $certDir)) {
    Write-Error "TLS certs directory not found: $certDir"
    exit 3
}

$fullchain = Join-Path $certDir "fullchain.pem"
$privkey = Join-Path $certDir "privkey.pem"
if (-not (Test-Path $fullchain) -or -not (Test-Path $privkey)) {
    Write-Error "TLS certificate files missing in $certDir. Expected: fullchain.pem and privkey.pem"
    exit 4
}

Write-Host "Environment file and TLS certs present. Validation passed."
exit 0
