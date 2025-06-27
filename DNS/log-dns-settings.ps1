# log-dns-settings.ps1
# This script collects DNS settings from specific endpoint and logs the settings

# Set log file path
$logPath = "\\HOSP-DC1\CentralLogs\dns-settings.log"

# Function to write message to log with timestamp
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logPath -Append
}

Log-Message "=== DNS Settings Log Start for $env:COMPUTERNAME ==="

# Get only IPv4 interfaces with at least one DNS address
$netAdapters = Get-DnsClientServerAddress | Where-Object {
    $_.AddressFamily -eq 2 -and $_.ServerAddresses -and $_.ServerAddresses.Count -gt 0
}

# Collect each adapter interface name and dns server IPs 
foreach ($adapter in $netAdapters) {
    $dnsServers = $adapter.ServerAddresses -join ", "
    Log-Message "Interface: $($adapter.InterfaceAlias) - DNS Servers: $dnsServers"
}

Log-Message "=== DNS Settings Log End for $env:COMPUTERNAME ===`n"
