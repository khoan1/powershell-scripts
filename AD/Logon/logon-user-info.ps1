# logon-user-info.ps1
# This script logs domain user logon info (username, timestamp, machine) to central log folder

# Path to central log file on DC
$logPath = "\\HOSP-DC1\CentralLogs\user-logons.log"

# Prepare log entry with username, machine name, timestamp
$user = $env:USERNAME
$machine = $env:COMPUTERNAME
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$logEntry = "[$time] User '$user' logged on to machine '$machine'"

# Append to log file - create file if it doesn't exist
Add-Content -Path $logPath -Value $logEntry


