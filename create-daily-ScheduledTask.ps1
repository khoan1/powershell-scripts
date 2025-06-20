# create-daily-ScheduledTask.ps1
# This script prompts for input and creates a scheduled daily task to run a PowerShell script, with time format validation

# Prompt for user input
$scriptPath = Read-Host "Enter the full path of the PowerShell script to run"
$taskName = Read-Host "Enter the name of the scheduled task"
$taskDescription = Read-Host "Enter a description for the task"

# Validate if script path exists
if (-Not (Test-Path $scriptPath)) {
    Write-Host "[X] Script file not found at path: $scriptPath" -ForegroundColor Red
    exit
}

# Prompt and validate time input, repeat until time input is valid
do {
    $taskTimeInput = Read-Host "Enter the time to run the task (e.g., 2:00AM or 14:00)"
    $parsedTime = [datetime]::MinValue   # initialize $parsedTime to a datetime object
    $isValidTime = [DateTime]::TryParse($taskTimeInput, [ref]$parsedTime)  # returns true or false, if true then saves DateTime into $parsedTime

    if (-Not $isValidTime) {
        Write-Host "[X] Invalid time format. Please try again." -ForegroundColor Yellow
    }
} until ($isValidTime)

# Create trigger and action
$trigger = New-ScheduledTaskTrigger -Daily -At $parsedTime
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries    # parameters for laptop or tablet

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description $taskDescription -Settings $settings

Write-Host "`n[O] Scheduled task '$taskName' created successfully." -ForegroundColor Green
