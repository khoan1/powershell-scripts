# network-reset-tool.ps1
# This script performs basic network reset: release IP, renew IP, and flush DNS

Write-Host "===Network Reset Tool===" -ForegroundColor Cyan
Write-Host "This will release IP, renew IP, and flush DNS..." -ForegroundColor Gray

# Function to run and show command
function Run-NetCommand {
    param (
        [string]$command,    # initialize $command as string object
        [Parameter(ValueFromRemainingArguments=$true)]   # enables array object below to accept more than 1 argument
        [string[]]$args      # initialize $args as string array object
    )
    # write the command to console then run command
    Write-Host "`n[>] Running: $command $($args -join ' ')" -ForegroundColor Yellow
    & $command @args
}

# Step 1: Release IP
Run-NetCommand "ipconfig" "/release"

# Step 2: Renew IP
Run-NetCommand "ipconfig" "/renew"

# Step 3: Flush DNS
Run-NetCommand "ipconfig" "/flushdns"

Write-Host "`n[O] Network reset completed." -ForegroundColor Green
