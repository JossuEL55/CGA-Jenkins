param(
    [Parameter(Position = 0)]
    [string]$TargetUrl = $env:TARGET_URL
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($TargetUrl)) {
    Write-Error 'Usage: ./scripts/smoke-test.ps1 -TargetUrl <base-url> (or set TARGET_URL).'
    exit 2
}

$baseUrl = $TargetUrl.TrimEnd('/')

try {
    $health = Invoke-WebRequest -Uri "$baseUrl/health" -UseBasicParsing
    if ($health.StatusCode -ne 200) { throw "/health returned HTTP $($health.StatusCode)." }
    Write-Host "OK: $baseUrl/health returned HTTP 200."

    $homeResponse = Invoke-WebRequest -Uri "$baseUrl/" -UseBasicParsing
    if ($homeResponse.StatusCode -ne 200) { throw "/ returned HTTP $($homeResponse.StatusCode)." }
    Write-Host "OK: $baseUrl/ returned HTTP 200."

    if ($homeResponse.Content -notlike '*CGA Metrology System*') {
        throw "The home page does not contain 'CGA Metrology System'."
    }
    Write-Host "OK: the home page contains 'CGA Metrology System'."
    Write-Host 'Smoke test completed successfully.'
}
catch {
    Write-Error "Smoke test failed: $($_.Exception.Message)"
    exit 1
}
