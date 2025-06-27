# check-password-expiry.ps1
# This scripts will check how many days until user password will expire
# A warning box will show and warn user if password expiration date is less than or equal to 10 days

# Get path to create log file
$logPath = "\\HOSP-DC1\CentralLogs\password-expiry.log"

$warningThresholdDays = 10

# Get username and domain
$username = $env:USERNAME
$domain = $env:USERDOMAIN

try {
    # Saves net user output to string array
    $netUserOutput = net user $username /domain

    # Match line that starts with "Password expires" (case-insensitive, flexible spacing)
    $expiryLine = $netUserOutput | Where-Object { $_.Trim() -match '^\s*Password expires\s+(.+)$' }

    # Check if password expiration date line exists or not
    if ($expiryLine) {
        # Remove the "Password expires" part and only save "M/d/yyyy h:mm:ss tt" to $expiryString
        $expiryString = ($expiryLine -replace '^\s*Password expires\s+', '').Trim()

        # Check if password is set to expire or never expire
        if ($expiryString -eq "Never") {
            $logMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $username - Password does not expire."
        } else {
            # Adjust date format based on locale if needed, currently set to system default of US format
            $expiryDate = [datetime]::ParseExact($expiryString, "M/d/yyyy h:mm:ss tt", $null)
            $daysLeft = ($expiryDate - (Get-Date)).Days
            $logMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $username - Password expires in $daysLeft day(s)."

            # Check if days left are less than 10 and still a future date
            if ($daysLeft -le $warningThresholdDays -and $daysLeft -ge 0) {
                # Show warning dialog box when user logs in
                Add-Type -AssemblyName PresentationFramework
                [System.Windows.MessageBox]::Show("⚠ Your password will expire in $daysLeft day(s). Please update it soon.", "Password Expiry Warning")
            }
        }
        $logMsg | Out-File -FilePath $logPath -Append

    } else {
        throw "Could not find a matching 'Password expires' line in net user output."
    }
}
catch {
    $errMsg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $username - Error checking password expiry: $_"
    $errMsg | Out-File -FilePath $logPath -Append
}
