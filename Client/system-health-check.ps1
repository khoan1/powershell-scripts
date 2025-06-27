# system-health-check.ps1
# This script performs system file integrity check, DISM repair, clears Windows Update cache, and restarts Windows Update services

Write-Host "***Starting System Health Check***" -ForegroundColor Cyan

# Step 1: Run SFC
Write-Host "`n===Running System File Checker (sfc /scannow)===" -ForegroundColor Yellow
sfc /scannow

# Step 2: Run DISM Health Check & Restore
Write-Host "`n===Running DISM Health Check===" -ForegroundColor Yellow
DISM /Online /Cleanup-Image /ScanHealth

Write-Host "`n===Running DISM Restore Health===" -ForegroundColor Yellow
DISM /Online /Cleanup-Image /RestoreHealth

# Step 3: Clear Windows Update Cache
Write-Host "`n===Stopping Windows Update services===" -ForegroundColor Yellow
Stop-Service wuauserv -Force
Stop-Service bits -Force
Start-Sleep -Seconds 2

$updateCache = "$env:SystemRoot\SoftwareDistribution"
Write-Host "===Clearing Windows Update cache at: $updateCache==="
Remove-Item "$updateCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Step 4: Restart Services
Write-Host "`n===Restarting Windows Update services===" -ForegroundColor Yellow
Start-Service wuauserv
Start-Service bits

Write-Host "`n[O] System health check completed." -ForegroundColor Green
