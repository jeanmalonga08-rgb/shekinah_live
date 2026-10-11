param(
    [string]$Device = "chrome"
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\..")

Write-Host "Shekinah Live — lancement Web ($Device)" -ForegroundColor Cyan
flutter pub get
flutter run -d $Device
