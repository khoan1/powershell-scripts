# dhcp-lease-cleaner.ps1
# This script checks for inactive or expired leases and removes them accordingly

# Set DHCP server and logpath
$dhcpServer = "HOSP-DC1"
$logPath = "\\HOSP-DC1\CentralLogs\dhcp-expired-lease-cleanup.log"

# Function to write message to log with timestamp
function Log-Message {
    param([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logPath -Append
}

Log-Message "=== DHCP Lease Cleanup Start ==="

try {
    # Get all DHCP scopes
    $currentScopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer

    foreach ($scope in $currentScopes) {
        $scopeId = $scope.ScopeId
        Log-Message "Checking scope: $scopeId"

        # Get all expired or inactive leases
        $currentLeases = Get-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $scopeId |
            Where-Object {
                ($_.AddressState -ne "Active") -or ($_.LeaseExpiryTime -lt (Get-Date))
            }

        if ($currentLeases.Count -eq 0) {
            Log-Message "No expired or inactive leases found in $scopeId."
        }

        foreach ($lease in $currentLeases) {
            $info = "Removing lease: IP=$($lease.IPAddress), MAC=$($lease.ClientId), State=$($lease.AddressState), Expiry=$($lease.LeaseExpiryTime)"
            Log-Message $info

            # Remove the lease (WhatIf parameter is used to check if the expired / inactive leases are correct)
            Remove-DhcpServerv4Lease -ComputerName $dhcpServer -ScopeId $scopeId -IPAddress $lease.IPAddress -Confirm:$false -WhatIf
        }
    }
}
catch {
    Log-Message "Error during lease cleanup: $_"
}

Log-Message "=== DHCP Lease Cleanup End ==="
