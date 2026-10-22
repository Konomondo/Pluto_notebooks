param([ValidateSet('setup','test','serve','export')][string]$Action = 'serve', [string]$Julia = 'julia', [string]$CacheDepot = '')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$env:JULIA_PROJECT = Join-Path $repo 'slider-server-environment'
$env:JULIA_LOAD_PATH = '@;@stdlib'
$env:JULIA_DEPOT_PATH = Join-Path $repo '.local/julia-depot'
if ($CacheDepot) { $env:JULIA_DEPOT_PATH += ';' + (Resolve-Path -LiteralPath $CacheDepot).Path }
$env:JULIA_NUM_THREADS = '2'
$env:JULIA_NUM_PRECOMPILE_TASKS = '2'
$env:GKSwstype = '100'
$script = switch ($Action) {
    'setup' { 'tools/setup.jl' }
    'test' { 'tools/test_notebooks.jl' }
    'export' { 'tools/export_notebooks.jl' }
    'serve' { 'slider-server-environment/run_server.jl' }
}
& $Julia --startup-file=no (Join-Path $repo $script)
if ($LASTEXITCODE -ne 0) { throw "Julia command failed: $LASTEXITCODE" }
