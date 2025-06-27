# ntp-sync-startup.ps1
# This script syncs time with domain controller (NTP) and logs the result

# Define log file path (shared folder on DC)
$logPath = "\\HOSP-DC1\CentralLogs\ntp-sync.log"

# Function to write timestamped log entries
function Log-Message {
    param([string]$msg)
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg" | Out-File -FilePath $logPath -Append
}

Log-Message "=== Starting NTP time sync script ==="

try {
    # Force sync source to HOSP-DC1 (DC)
    w32tm /config /syncfromflags:manual /manualpeerlist:"HOSP-DC1" /update | Out-Null

    # Restart Windows Time service
    net stop w32time | Out-Null
    net start w32time | Out-Null

    # Force time sync
    w32tm /resync /nowait | Out-Null

    Log-Message "Time sync completed successfully."
}
catch {
    Log-Message "Error during time sync: $_"
}

Log-Message "=== Script complete ===`n"
