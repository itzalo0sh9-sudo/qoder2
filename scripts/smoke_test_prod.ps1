param(
    [string]$EnvFile = ".env.prod",
    [int]$WaitSeconds = 180
)

Write-Host "Starting production smoke test using $EnvFile"

if (-not (Test-Path $EnvFile)) {
    # If running in CI, try to construct .env.prod from environment variables
    if ($Env:CI -or $Env:GITHUB_ACTIONS) {
        Write-Host "$EnvFile missing — attempting to generate from environment variables for CI run"
        $content = @()
        if ($Env:DATABASE_URL) { $content += "DATABASE_URL=$($Env:DATABASE_URL)" }
        if ($Env:FINANCE_DATABASE_URL) { $content += "FINANCE_DATABASE_URL=$($Env:FINANCE_DATABASE_URL)" }
        if ($Env:HR_DATABASE_URL) { $content += "HR_DATABASE_URL=$($Env:HR_DATABASE_URL)" }
        if ($Env:NGINX_CERT && $Env:NGINX_KEY) { $content += "NGINX_CERT=/etc/nginx/certs/fullchain.pem"; $content += "NGINX_KEY=/etc/nginx/certs/privkey.pem" }
        if ($content.Count -gt 0) {
            $content | Out-File -FilePath $EnvFile -Encoding utf8
            Write-Host "Generated $EnvFile from environment variables"
        } else {
            Write-Error "Missing $EnvFile and no env vars to construct it. Create it from .env.prod.example and set production secrets."
            exit 2
        }
    } else {
        Write-Error "Missing $EnvFile. Create it from .env.prod.example and set production secrets."
        exit 2
    }
}

# Accept self-signed certificates for smoke-test requests (only for local testing)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Helper: wait until a TCP port is open on localhost
function Wait-Port($port, $timeoutSeconds) {
    $end = (Get-Date).AddSeconds($timeoutSeconds)
    while ((Get-Date) -lt $end) {
        try {
            $sock = New-Object System.Net.Sockets.TcpClient
            $async = $sock.BeginConnect('127.0.0.1', $port, $null, $null)
            $wait = $async.AsyncWaitHandle.WaitOne(1000)
            if ($wait -and $sock.Connected) { $sock.Close(); return $true }
            $sock.Close()
        } catch { }
        Start-Sleep -Seconds 1
    }
    return $false
}

# Bring up prod compose
Write-Host "Bringing up services..."
docker compose -f docker-compose.prod.yml --env-file $EnvFile up -d --build

$end = (Get-Date).AddSeconds($WaitSeconds)

# Discover published host ports for services (docker will publish random host ports)
Write-Host "Discovering published host ports assigned by Docker..."
function Get-PublishedPort($serviceName, $containerPort) {
    try {
        $out = docker compose -f docker-compose.prod.yml ps -q $serviceName
        if (-not $out) { return $null }
        $containerId = $out.Trim()
        # docker port returns e.g. 0.0.0.0:32768
        $mapping = docker port $containerId $containerPort 2>$null
        if (-not $mapping) { return $null }
        $parts = $mapping -split ':'
        return [int]$parts[-1]
    } catch {
        return $null
    }
}

# Give containers a few seconds to publish ports
Start-Sleep -Seconds 3

$nginx_http_port = Get-PublishedPort nginx 80
$nginx_https_port = Get-PublishedPort nginx 443
$prometheus_port = Get-PublishedPort prometheus 9090
$grafana_port = Get-PublishedPort grafana 3000

if ($nginx_http_port) { Write-Host "nginx HTTP published on host port $nginx_http_port" } else { Write-Warning "Could not discover nginx HTTP host port" }
if ($nginx_https_port) { Write-Host "nginx HTTPS published on host port $nginx_https_port" } else { Write-Warning "Could not discover nginx HTTPS host port" }
if ($prometheus_port) { Write-Host "prometheus published on host port $prometheus_port" } else { Write-Warning "Could not discover prometheus host port" }
if ($grafana_port) { Write-Host "grafana published on host port $grafana_port" } else { Write-Warning "Could not discover grafana host port" }

function Wait-Health($url, $timeoutSeconds) {
    $end = (Get-Date).AddSeconds($timeoutSeconds)
    while ((Get-Date) -lt $end) {
        try {
            # Use TLS and follow redirects. Ignore cert errors globally above.
            $headers = @{ 'X-Internal-Health' = 'true' }
            $r = Invoke-WebRequest -Uri $url -Headers $headers -MaximumRedirection 5 -TimeoutSec 6 -ErrorAction Stop
            if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { return $true }
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    return $false
}

$services = @{}
# health endpoints go through nginx (use discovered HTTPS host port if available, otherwise try HTTP port)
if ($nginx_https_port) {
    $baseHost = "https://localhost:$nginx_https_port"
} elseif ($nginx_http_port) {
    $baseHost = "http://localhost:$nginx_http_port"
} else {
    $baseHost = 'https://localhost'
}
$services['sales'] = "$baseHost/health/sales"
$services['finance'] = "$baseHost/health/finance"
$services['hr'] = "$baseHost/health/hr"

if ($prometheus_port) { $services['prometheus'] = "http://localhost:$prometheus_port/-/ready" } else { $services['prometheus'] = 'http://localhost:9090/-/ready' }
if ($grafana_port) { $services['grafana'] = "http://localhost:$grafana_port/" } else { $services['grafana'] = 'http://localhost:3000/' }

$failed = @()
foreach ($k in $services.Keys) {
    Write-Host "Checking $k -> $($services[$k])"
    $ok = $false
    if (Wait-Health $services[$k] $WaitSeconds) {
        $ok = $true
    } else {
        # If this is an nginx-proxied health endpoint and we tried HTTPS, attempt HTTP fallback
        if ($nginx_http_port -and $services[$k] -match '^https://') {
            $alt = $services[$k] -replace '^https://', 'http://'
            # replace host:port to use the discovered nginx HTTP port if necessary
            if ($nginx_https_port) {
                # services were constructed like https://localhost:$nginx_https_port/path
                $alt = $alt -replace ":$nginx_https_port", ":$nginx_http_port"
            }
            Write-Host "HTTPS check failed for $k - trying HTTP fallback -> $alt"
            if (Wait-Health $alt $WaitSeconds) { $ok = $true }
        }
    }

    if (-not $ok) {
        Write-Host "Health check failed for $k"
        $failed += $k
    } else {
        Write-Host "$k is healthy"
    }
}

if ($failed.Count -gt 0) {
    Write-Error "Smoke test failed for: $($failed -join ', ')"
    Write-Host "Collecting logs (last 200 lines) for failed services..."
    foreach ($s in $failed) {
        switch ($s) {
            'sales' { docker compose -f docker-compose.prod.yml logs --tail 200 sales-api }
            'finance' { docker compose -f docker-compose.prod.yml logs --tail 200 finance-api }
            'hr' { docker compose -f docker-compose.prod.yml logs --tail 200 hr-api }
            'prometheus' { docker compose -f docker-compose.prod.yml logs --tail 200 prometheus }
            'grafana' { docker compose -f docker-compose.prod.yml logs --tail 200 grafana }
        }
    }
    Write-Host "Tearing down services (keeps volumes by default)..."
    docker compose -f docker-compose.prod.yml down
    exit 1
}

Write-Host "All services healthy. Running a minimal API check against sales API..."
try {
    $r = Invoke-WebRequest http://localhost/api/sales/ -UseBasicParsing -TimeoutSec 10
    Write-Host "Sales API root response: $($r.StatusCode)"
} catch {
    Write-Warning "Sales API root request failed: $_"
}

Write-Host "Smoke tests passed. Tearing down..."
docker compose -f docker-compose.prod.yml down
exit 0
