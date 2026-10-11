# Bump version before flutter build appbundle (Windows).
# See scripts/bump_version_for_aab.py for the versioning policy.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

python (Join-Path $PSScriptRoot "bump_version_for_aab.py") @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
