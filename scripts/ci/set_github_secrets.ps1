<#
.scripts/ci/set_github_secrets.ps1

Purpose:
 - Template PowerShell script that sets required GitHub repository secrets using the `gh` CLI.
 - This script reads secret values from environment variables (safer) and calls `gh secret set`.

# USAGE
# 1. Install GitHub CLI and run `gh auth login`.
# 2. Export the required environment variables locally (or use a CI runner secrets store).
# 3. Run this script in the repo root: `.	ests\scripts\ci\set_github_secrets.ps1`

Note: This script does NOT store values in the repo. It simply calls `gh secret set`.
#>

param(
    [string]$Repo = "itzalo0sh9-sudo/qoder2"
)

function Set-SecretIfPresent($name, $envVar) {
    $value = (Get-Item "env:$envVar" -ErrorAction SilentlyContinue).Value
    if (-not [string]::IsNullOrEmpty($value)) {
        Write-Host "Setting secret $name from env var $envVar..."
        gh secret set $name --body $value --repo $Repo
    } else {
        Write-Host "Skipping $name — environment variable $envVar not set"
    }
}

Write-Host "Ensure gh is installed and authenticated (gh auth login). Repo: $Repo"

# Core runtime secrets
Set-SecretIfPresent -name "RUN_SMOKE_TEST" -envVar "RUN_SMOKE_TEST"
Set-SecretIfPresent -name "DB_HOST" -envVar "DB_HOST"
Set-SecretIfPresent -name "DB_PORT" -envVar "DB_PORT"
Set-SecretIfPresent -name "DB_USER" -envVar "DB_USER"
Set-SecretIfPresent -name "DB_PASSWORD" -envVar "DB_PASSWORD"
Set-SecretIfPresent -name "DB_NAME" -envVar "DB_NAME"

# Docker registry (optional)
Set-SecretIfPresent -name "DOCKER_REGISTRY" -envVar "DOCKER_REGISTRY"
Set-SecretIfPresent -name "DOCKER_USERNAME" -envVar "DOCKER_USERNAME"
Set-SecretIfPresent -name "DOCKER_PASSWORD" -envVar "DOCKER_PASSWORD"

# TLS certs (optional) - prefer using a secrets manager for large certs
Set-SecretIfPresent -name "TLS_CERT" -envVar "TLS_CERT"
Set-SecretIfPresent -name "TLS_KEY" -envVar "TLS_KEY"

Write-Host "Done. Verify secrets in GitHub repository settings -> Secrets"
