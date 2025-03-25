<#
.SYNOPSIS
    Uninstalls a winget app.
.DESCRIPTION
    This uninstalls an app using winget, windows package manager.
    The app ID should always be something like 'Notepad++.Notepad++' and never something like 'XP99DVCPGKTXNJ'.
    The latter are apps from the Microsoft Store and can be packaged natively in Intune.
    Since winget is largely a user-based tool, there is some extra work we have to do to run this as system.
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
Start-Transcript -Path "C:\MSUDenver\Logs\$PackageName\$PackageName-Install-$date.log" -Append
  
Write-Host "Trying to uninstall $($PackageName)"

try {        
    $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller____8wekyb3d8bbwe"
    if ($ResolveWingetPath) {
        $WingetPath = $ResolveWingetPath[-1].Path
    }

    $config
    Set-Location $wingetpath

    & $WingetPath\winget.exe uninstall $PackageName --silent
}
catch {
    Throw "Failed to uninstall $($PackageName)"
}

Stop-Transcript