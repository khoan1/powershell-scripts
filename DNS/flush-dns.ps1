# flush-dns.ps1
# This script flushes the local DNS cache and logs the action

# Log file location
$logPath = "\\HOSP-DC1\CentralLogs\dns-flush.log"

# Get current user
$username = $env:USERNAME

# Try flushing DNS
try {
    ipconfig /flushdns | Out-Null
    $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $username - DNS cache flushed successfully."
}
catch {
    $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $username - Error flushing DNS: $_"
}

# Write to log file
$msg | Out-File -FilePath $logPath -Append
