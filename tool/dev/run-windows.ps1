$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\..")

Write-Host "Shekinah Live — lancement Windows" -ForegroundColor Cyan

$doctor = flutter doctor -v 2>&1 | Out-String
if ($doctor -match "Visual Studio is missing necessary components") {
    Write-Host ""
    Write-Host "Visual Studio C++ requis pour Windows." -ForegroundColor Yellow
    Write-Host "Installez 'Desktop development with C++' puis relancez." -ForegroundColor Yellow
    Write-Host "Voir: tool/dev/DEV_SANS_TELEPHONE.md" -ForegroundColor Yellow
    Write-Host ""
}

flutter pub get
flutter run -d windows
