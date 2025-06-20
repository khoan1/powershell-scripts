# check-system-events.ps1
# This script scans System log for Critical and Error level events in the last 24 hours (can be changed to any time window)
# If events are found, readable output will be saved to RecentSysEvent.log
# Need to be run with administrative privileges for log file access

$timeWindow = (Get-Date).AddHours(-24)    # indicates last 24 hours time window

$logFile = "$env:SystemDrive\RecentSysEvent.log"

Write-Output "`n***Checking for Critical and Error events in the System log (last 24 hours)***"

# scans for Critical and Error level events for indicated time window
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Level = 1, 2  # 1 = Critical level, 2 = Error level
    StartTime = $timeWindow
} -ErrorAction SilentlyContinue

# Check if Critical and Error level events were found
if ($events.Count -eq 0) {
    Write-Output "[O] No critical or error events found in the last 24 hours."
} else {
    Write-Output "[!] Found $($events.Count) events:"

    # Display events info on screen in table format
    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Format-Table -Wrap -AutoSize

    # Format events found and write to log file
    "===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Add-Content $logFile
    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Format-Table -Wrap | Out-String | Add-Content -Path $logFile
}
