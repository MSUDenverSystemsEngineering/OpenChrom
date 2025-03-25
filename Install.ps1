<#
.SYNOPSIS
    Installs a winget app.
.DESCRIPTION
    This installs an app using winget, windows package manager.
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

# Check to see if the app installer is available and if not, install it.
$AppInstaller = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq Microsoft.DesktopAppInstaller

If($AppInstaller.Version -lt "2022.506.16.0") {

    Write-Host "Winget is not installed, trying to install latest version from Github" -ForegroundColor Yellow

    Try {
            
        Write-Host "Creating Winget Packages Folder" -ForegroundColor Yellow

        if (!(Test-Path -Path C:\ProgramData\WinGetPackages)) {
            New-Item -Path C:\ProgramData\WinGetPackages -Force -ItemType Directory
        }

        Set-Location C:\ProgramData\WinGetPackages

        #Downloading Packagefiles
        #Microsoft.UI.Xaml.2.7.0
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0" -OutFile "C:\ProgramData\WinGetPackages\microsoft.ui.xaml.2.7.0.zip"
        Expand-Archive C:\ProgramData\WinGetPackages\microsoft.ui.xaml.2.7.0.zip -Force
        #Microsoft.VCLibs.140.00.UWPDesktop
        Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "C:\ProgramData\WinGetPackages\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        #Winget
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\ProgramData\WinGetPackages\Winget.msixbundle"
        #Installing dependencies + Winget
        Add-ProvisionedAppxPackage -online -PackagePath:.\Winget.msixbundle -DependencyPackagePath .\Microsoft.VCLibs.x64.14.00.Desktop.appx,.\microsoft.ui.xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.Appx -SkipLicense

        Write-Host "Starting sleep for Winget to initiate" -Foregroundcolor Yellow
        Start-Sleep 2
    }
    Catch {
        Throw "Failed to install Winget"
        Break
    }

    }
Else {
    Write-Host "Winget already installed, moving on" -ForegroundColor Green
}
#Trying to install Package with Winget
IF ($PackageName){
    try {
        Write-Host "Installing $($PackageName) via Winget" -ForegroundColor Green

        $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
        $config
        Set-Location $wingetpath

        .\winget.exe install $PackageName --silent --accept-source-agreements --accept-package-agreements
        Stop-Transcript
    }
    Catch {
        Throw "Failed to install package $($_)"
        Stop-Transcript
        exit 3
    }
}
Else {
    Write-Host "Package $($PackageName) not available" -ForegroundColor Yellow
    Stop-Transcript
    exit 2
}