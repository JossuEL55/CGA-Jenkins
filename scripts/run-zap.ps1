param(
    [Parameter(Position = 0)]
    [string]$TargetUrl = $env:TARGET_URL,

    [string]$ReportDirectory = (Join-Path (Get-Location) 'zap-reports')
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($TargetUrl)) {
    Write-Error 'Usage: ./scripts/run-zap.ps1 -TargetUrl <url> (or set TARGET_URL).'
    exit 2
}

New-Item -ItemType Directory -Force -Path $ReportDirectory | Out-Null
$resolvedReportDirectory = (Resolve-Path $ReportDirectory).Path

Write-Host "Running OWASP ZAP Baseline against $TargetUrl"
Write-Host "Reports will be written to $resolvedReportDirectory"

docker run --rm `
    --volume "${resolvedReportDirectory}:/zap/wrk:rw" `
    ghcr.io/zaproxy/zaproxy:stable `
    zap-baseline.py -t $TargetUrl -I -r zap-report.html -J zap-report.json

if ($LASTEXITCODE -ne 0) {
    Write-Error "ZAP Baseline failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Write-Host 'ZAP Baseline completed. Review zap-report.html and zap-report.json.'
