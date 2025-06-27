# clear-print-queue.ps1
# This script checks for stuck print jobs and clears the print queue if needed
# Please run this script with administrative privileges

Write-Host "===Checking for stuck print jobs===" -ForegroundColor Cyan

# Get all print jobs from every printer connected to the system
$printJobs = Get-Printer | ForEach-Object { Get-PrintJob -PrinterName $_.Name -ErrorAction SilentlyContinue }

# Check if there are any stuck print job(s)
if ($printJobs.Count -eq 0) {
    Write-Host "[O] No print jobs found. Print queue is already clear." -ForegroundColor Green
} else {
    Write-Host "[!] Found $($printJobs.Count) print job(s). Attempting to clear the queue..." -ForegroundColor Yellow

    try {
        # Stop the print spooler service
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Seconds 2     # wait 2 seconds for all process to finish before moving on

        # Clear the spool folder
        $spoolFolder = "$env:SystemRoot\System32\spool\PRINTERS"
        Remove-Item "$spoolFolder\*" -Force -ErrorAction SilentlyContinue

        # Restart the print spooler
        Start-Service -Name Spooler

        Write-Host "[O] Print queue cleared successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "[X] Failed to clear print queue: $_" -ForegroundColor Red
    }
}
