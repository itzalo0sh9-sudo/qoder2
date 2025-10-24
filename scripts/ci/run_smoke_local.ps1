<#
.scripts/ci/run_smoke_local.ps1

Purpose:
 - Helper script to run the production docker-compose stack locally and then execute the smoke test.
 - It will create `.env.prod` from environment variables if missing (the smoke script also supports this), bring up the compose stack, wait a bit, run the smoke test, and tear down.

USAGE (PowerShell):
  # Ensure environment variables are set or create a minimal .env.prod in the repo root
  $env:DB_HOST = "postgres"
  $env:DB_PORT = "5432"
  $env:DB_USER = "postgres"
  $env:DB_PASSWORD = "changeme"
  $env:DB_NAME = "qoder2"

  .\scripts\ci\run_smoke_local.ps1

Warning: This will run containers on your machine and may overwrite ports. Use in a safe local/staging environment.
#>

Write-Host "Preparing .env.prod from environment variables (if missing)"
if (-not (Test-Path -Path ".env.prod")) {
    $content = @()
    if ($env:DB_HOST) { $content += "DB_HOST=$($env:DB_HOST)" }
    if ($env:DB_PORT) { $content += "DB_PORT=$($env:DB_PORT)" }
    if ($env:DB_USER) { $content += "DB_USER=$($env:DB_USER)" }
    if ($env:DB_PASSWORD) { $content += "DB_PASSWORD=$($env:DB_PASSWORD)" }
    if ($env:DB_NAME) { $content += "DB_NAME=$($env:DB_NAME)" }
    if ($content.Count -gt 0) {
        $content -join "`n" | Set-Content -Path .env.prod
        Write-Host ".env.prod generated"
    } else {
        Write-Host "No DB environment variables found — ensure .env.prod exists or set env vars."; exit 1
    }
} else {
    Write-Host ".env.prod already exists — using existing file"
}

Write-Host "Bringing up docker-compose.prod stack (detached)"
docker compose -f docker-compose.prod.yml up -d --build

Write-Host "Waiting 12s for services to start..."
Start-Sleep -Seconds 12

Write-Host "Running smoke test script"
.\scripts\smoke_test_prod.ps1

$rc = $LASTEXITCODE
Write-Host "Smoke test finished with exit code $rc"

Write-Host "(Optional) Tearing down stack — uncomment if you want automatic teardown"
# docker compose -f docker-compose.prod.yml down

exit $rc
