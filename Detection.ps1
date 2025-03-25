<#
.SYNOPSIS
    Detects if an winget app is installed or not.
.DESCRIPTION
    There are three possible outcomes for this script:
    1. The app is not installed ("not detected", exit code 1)
    2. The app is installed but an update is available ("not detected", exit code 1)
    3. The app is installed and there is no update available ("detected", exit code 0)

    Because winget displays loading animations for all queries, piping the results into a variable produces blank lines and dashes.
    This seems to be a predictable amount each time, so for that reason, in lines 40, 44, and 49, we treat the variables as arrays and
    access the last element of the array which contains the text we want.
    If winget ever changes how the loading animations work we may want to switch to disabling them in a winget settings file instead.
.NOTES
	Author: Ryan McKenna
    Date: 3/25/2025
#>

#The Winget package ID
$PackageName = "Lablicate.OpenChrom"

#See if the MSU Denver directory already exists, if not, then create it
if (-not (Test-Path -Path C:\MSUDenver\Logs -PathType Container))
{
    New-Item -Path "C:\MSUDenver\" -Name "Logs" -ItemType "directory"
}

# Start the transcript.
$date = Get-Date -Format "yyyy-MM-dd-hh-mm-ss"
Start-Transcript -Path "C:\MSUDenver\Logs\$PackageName\$PackageName-Detection-$date.log" -Append

# Make sure that we can access the app installer (winget).
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$config
Set-Location $wingetpath

# Check to see if the app is installed and if an update is available.
$InstalledApps = .\winget.exe list --id $PackageName --accept-source-agreements
$UpdateApps = .\winget.exe list --id $PackageName --upgrade-available --accept-source-agreements

if (($InstalledApps[$InstalledApps.count-1] -eq "No installed package found matching input criteria.")) {
    Write-Warning "$($PackageName) not installed so not detected."
    Stop-Transcript
    Exit 1
}
elseif ((!($InstalledApps[$InstalledApps.count-1] -eq "No installed package found matching input criteria.")) -and (!($UpdateApps[$UpdateApps.count-1] -eq "No installed package found matching input criteria."))) {
    Write-Warning "$($PackageName) is installed but an update is available so not detected."
    Stop-Transcript
    Exit 1

}
elseif ((!($InstalledApps[$InstalledApps.count-1] -eq "No installed package found matching input criteria.")) -and ($UpdateApps[$UpdateApps.count-1] -eq "No installed package found matching input criteria.")) {
    Write-Host "$($PackageName) is installed and there is no update available so yes detected."
    Stop-Transcript
    Exit 0

}