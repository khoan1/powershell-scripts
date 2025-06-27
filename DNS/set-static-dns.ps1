# set-static-dns.ps1
# This script sets static DNS servers on the primary active adapter and logs actions

# Define the log file location
$logPath = "\\HOSP-DC1\CentralLogs\set-dns.log"

# Function to log messages
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $msg" | Out-File -FilePath $logPath -Append
}

# Define DNS server IPs
$dnsServers = @("192.168.100.10")  # Replace with your internal DNS IPs

try {
    # Get primary active network adapter
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Sort-Object InterfaceMetric | Select-Object -First 1

    if ($adapter) {
        Log-Message "Found active adapter: $($adapter.Name)"

        # Set static DNS
        Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $dnsServers
        Log-Message "Set DNS servers to: $($dnsServers -join ', ') on adapter '$($adapter.Name)'"

        # Confirm current DNS settings
        $currentDNS = Get-DnsClientServerAddress -InterfaceAlias $adapter.Name
        foreach ($dns in $currentDNS.ServerAddresses) {
            Log-Message "Confirmed DNS: $dns"
        }
    } else {
        Log-Message "No active network adapter found. DNS not set."
    }
}
catch {
    Log-Message "Error setting DNS: $_"
}
