# audit-dhcp-leases.ps1
# This script records all leases from DHCP server and logs to file

# Define DHCP server name and log path
$dhcpServer = "HOSP-DC1"   # Can be replace with any DHCP server hostname or IP
$logPath = "\\HOSP-DC1\CentralLogs\dhcp-leases-audit.log"

# Function to write message to log with timestamp
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logPath -Append
}

Log-Message "=== DHCP Leases Audit Start ==="

try {
    # Get the current pool of IP addresses assigned to DHCP server
    $currentScope = Get-DhcpServerv4Scope -ComputerName $dhcpServer

    foreach ($scope in $currentScope) {
        $scopeId = $scope.ScopeId
        Log-Message "> Scope: $scopeId <"

        # Get all active DHCP leases
        $currentLeases = Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $scopeId | Where-Object { $_.AddressState -eq "Active" }

        foreach ($lease in $currentLeases) {
            $line = "IP: $($lease.IPAddress), MAC: $($lease.ClientId), Hostname: $($lease.HostName), Lease Expiry: $($lease.LeaseExpiryTime)"
            Log-Message $line
        }
    }
}
catch {
    Log-Message "Error retrieving DHCP leases: $_"
}

# Add timestamp to log end
Log-Message "=== DHCP Leases Audit End ==="
