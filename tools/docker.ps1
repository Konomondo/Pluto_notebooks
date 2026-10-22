param([ValidateSet('build','up','down','logs','pull')][string]$Action = 'build')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$env:JULIA_VERSION = (Get-Content -LiteralPath (Join-Path $repo '.julia-version') -Raw).Trim()
Push-Location $repo
try {
    switch ($Action) {
        'up' { docker compose up -d }
        'logs' { docker compose logs -f }
        default { docker compose $Action }
    }
    if ($LASTEXITCODE -ne 0) { throw "Docker command failed: $LASTEXITCODE" }
} finally { Pop-Location }
