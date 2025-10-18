param(
    [switch]$KeepUp
)

Write-Host "[test.ps1] Starting compose stack..."
docker compose up -d --build

Write-Host "[test.ps1] Waiting for services to report healthy..."
$urls = @("http://localhost:8001/health","http://localhost:8002/health","http://localhost:8003/health")
foreach ($u in $urls) {
    $ok = $false
    for ($i=0; $i -lt 30; $i++) {
        try {
            $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 300) { $ok = $true; break }
        } catch { Start-Sleep -Seconds 2 }
    }
    if (-not $ok) { Write-Error "Service $u did not become healthy in time"; exit 2 }
}

Write-Host "[test.ps1] Running pytest via sales-api-test..."
docker compose run --rm sales-api-test
$code = $LASTEXITCODE

if (-not $KeepUp) {
    Write-Host "[test.ps1] Tearing down compose stack..."
    docker compose down
}

exit $code
