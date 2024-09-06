param (
	[switch]$Brave,
	[switch]$Firefox,
	[switch]$Thorium,
	[switch]$Ui,
	[switch]$Defender,
	[switch]$Sab,
	[switch]$Diskclean,
	[switch]$Remove_edge
)

$tempDir = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $([System.Guid]::NewGuid())
New-Item $tempDir -ItemType Directory -Force | Out-Null
Push-Location $tempDir

# Install Brave Browser
if ($Brave) {
	& curl.exe -LSs "https://laptop-updates.brave.com/latest/winx64" -o "$tempDir\BraveSetup.exe"

	& "$tempDir\BraveSetup.exe" /silent /install 2>&1 | Out-Null

	do {
		$processesFound = Get-Process | Where-Object { "BraveSetup" -contains $_.Name } | Select-Object -ExpandProperty Name
		if ($processesFound) {
			Write-Output "Still running BraveSetup."
			Start-Sleep -Seconds 2
		} else {
			Remove-Item "$tempDir" -ErrorAction SilentlyContinue -Force -Recurse
		}
	} until (!$processesFound)

	Stop-Process -Name "brave" -Force -ErrorAction SilentlyContinue
	exit
}

# Install Firefox Browser
if ($Firefox) {
	Write-Output "Downloading Firefox..."
	& curl.exe -LSs "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -o "$tempDir\firefox.exe"
	Start-Process -FilePath "$tempDir\firefox.exe" -WindowStyle Hidden -ArgumentList '/S /ALLUSERS=1' -Wait 2>&1 | Out-Null
	exit
}

# Install Thorium browser
if ($Thorium) {
    Write-Output "Downloading Thorium..."
    $installer = ((Invoke-RestMethod -Uri "https://api.github.com/repos/Alex313031/Thorium-Win/releases/latest" -Headers @{ "User-Agent" = "Mozilla/5.0" }).assets | Where-Object { $_.name -like "*mini_installer.exe" }).browser_download_url
    if (-not $installer) { throw "Installer URL not found" }
    curl.exe -LSs $installer -o "$tempDir\thorium_mini_installer.exe"
    $process = Start-Process -FilePath "$tempDir\thorium_mini_installer.exe" -NoNewWindow -PassThru
    $installer_pid = $process.Id
    do {
    Start-Sleep -Seconds 1
    $installer_running = Get-Process -Id $installer_pid -ErrorAction SilentlyContinue
    } while ($installer_running)
    Start-Sleep -Seconds 10
    Get-Process -Name "thorium" -ErrorAction SilentlyContinue | Stop-Process
    Write-Output "Thorium has been installed."
    exit
}


# Install StartAllBack
if ($Ui) {
	Write-Output "Downloading StartAllBack..."
	& curl.exe -LSs "https://www.startallback.com/download.php" -o "$tempDir\startallback.exe"
	& "$tempDir\startallback.exe" /elevated /silent 2>&1 | Out-Null
	exit
}

# Activate StartAllBack
if ($Sab) {
	# https://github.com/winbo-yml-exe
  Stop-Process -Name StartAllBackCfg -ErrorAction SilentlyContinue
  
  $DLL = "StartAllBack\StartAllBackX64.dll"
  $UserDLL = "$Env:LocalAppData\$DLL"
  $SystemDLL64 = "$Env:ProgramFiles\$DLL"
  $SystemDLL32 = "${Env:ProgramFiles(x86)}\$DLL"
  $Paths = @()
  if(Test-Path -Path $UserDLL) { $Paths += ,$UserDLL }
  if(Test-Path -Path $SystemDLL64) { $Paths += ,$SystemDLL64 }
  if(Test-Path -Path $SystemDLL32) { $Paths += ,$SystemDLL32 }

  foreach($Path in $Paths) {
   $Backup = "$Path.bak"
   if(Test-Path -Path $Backup) {
    Remove-Item -Path $Path -Force
    Rename-Item -Path $Backup -NewName $Path
   } else {
    Copy-Item -Path $Path -Destination $Backup
    $Bytes = Get-Content $Path -Raw -Encoding Byte # -AsByteStream
    $String = $Bytes.ForEach('ToString', 'X') -join ' '
    $String = $String -replace '\b48 89 5C 24 8 55 56 57 48 8D AC 24 70 FF FF FF\b(.*)', '67 C7 1 1 0 0 0 B8 1 0 0 0 C3 90 90 90$1'
    [byte[]]$ModifiedBytes = -split $String -replace '^', '0x'
    Set-Content -Path $Path -Value $ModifiedBytes -Encoding Byte # -AsByteStream
   }
  }
  exit
}

# Download Defender Disabler
if ($Defender) {
	& curl.exe -LSs "https://github.com/pgkt04/defender-control/releases/latest/download/disable-defender.exe" -o "$tempDir\defender.exe"
	& "$tempDir\defender.exe" -s 2>&1 | Out-Null
	exit
}

# Edge remover (thanks to ShadowWhisperer for the script base)
if ($Remove_edge) {
    $winusrid = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Remove Edge-related registry keys
    @(
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge",
        "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}"
    ) | ForEach-Object { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }

    # Download the Edge uninstaller
    curl.exe -LSs "https://github.com/ShadowWhisperer/Remove-MS-Edge/raw/main/_Source/setup.exe" -o "$tempDir\edge_setup.exe"

    # Uninstall Edge if it exists
    if (Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application") {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempDir\edge_setup.exe`" --uninstall --system-level --force-uninstall > NUL 2>&1" -NoNewWindow -Wait
        Start-Sleep -Seconds 2
    }

    # Remove Edge apps
    $usrsid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $edgeappx = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like "*microsoftedge*" } | Select-Object -ExpandProperty PackageFullName

    foreach ($app in $edgeappx) {
        if ($app -notlike '*MicrosoftEdgeDevTools*') {
            $endOfLifePaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$usrsid\$app",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\$app",
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\$app"
            )
            $endOfLifePaths | ForEach-Object { New-Item -Path $_ -Force | Out-Null }
            Remove-AppxPackage -Package $app -ErrorAction SilentlyContinue
            Remove-AppxPackage -Package $app -AllUsers -ErrorAction SilentlyContinue
        }
    }

    # Remove directories and registry keys
    Remove-Item -Path "C:\ProgramData\Microsoft\EdgeUpdate" -Recurse -Force -ErrorAction SilentlyContinue

    # Remove shortcuts from user desktops
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
        $desktopPath = Join-Path -Path $_.FullName -ChildPath "Desktop"
        if (Test-Path $desktopPath) {
            @("edge.lnk", "Microsoft Edge.lnk") | ForEach-Object {
                $shortcutPath = Join-Path -Path $desktopPath -ChildPath $_
                if (Test-Path $shortcutPath) {
                    Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }

    # Remove scheduled tasks related to Edge
    $tasks = schtasks /query /fo csv | Select-Object -Skip 1 | Where-Object { $_ -match 'MicrosoftEdge' } | ForEach-Object {($_.Split(',')[0] -replace '"', '').Trim()}
    $tasks | ForEach-Object { schtasks /delete /tn $_ /f | Out-Null }

    # Remove Edge-related tasks from the System32 directory
    Get-ChildItem "C:\Windows\System32\Tasks" -Recurse -File -Name | Where-Object { $_ -like "MicrosoftEdge*" } | ForEach-Object { Remove-Item "C:\Windows\System32\Tasks\$_" -Force -ErrorAction SilentlyContinue }

    # Remove Edge services and registry entries
    foreach ($svc in @("edgeupdate", "edgeupdatem")) {
        sc.exe delete $svc 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$svc" -Recurse -Force -ErrorAction SilentlyContinue 
        }
    }

    # Remove Edge registry keys if Edge executable is not found
    if (!(Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\pwahelper.exe")) {
        Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue 
    }

    # Remove Edge-related directories
    Get-ChildItem "C:\Windows\SystemApps" -Directory -Recurse | Where-Object { $_.Name -like "Microsoft.MicrosoftEdge*" } | ForEach-Object {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f `"$($_.FullName)`" /r /d y && icacls `"$($_.FullName)`" /grant administrators:F /t && rd /s /q `"$($_.FullName)`" > NUL 2>&1" -NoNewWindow -Wait | Out-Null
    }

    # Remove Microsoft Edge executables
    Get-ChildItem "C:\Windows\System32" -Filter "MicrosoftEdge*.exe" | ForEach-Object {
        $filePath = $_.FullName
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f `"$filePath`" > NUL 2>&1" -NoNewWindow -Wait | Out-Null
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c icacls `"$filePath`" /inheritance:e /grant `"$winusrid`:(OI)(CI)F /T /C" -NoNewWindow -Wait | Out-Null
        Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
    }

    # Remove Edge .dat file
    Remove-Item -Path "C:\Program Files (x86)\Microsoft\Edge\Edge.dat" -Force -ErrorAction SilentlyContinue

    # Remove Temp directory
    Remove-Item -Path "C:\Program Files (x86)\Microsoft\Temp" -Recurse -Force -ErrorAction SilentlyContinue
}


# Clean Disk
if ($Diskclean) {
	function DiskClean {
	Get-Process -Name cleanmgr -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
	$baseKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
	$regValues = @{
		"Active Setup Temp Folders" = 2
		"BranchCache" = 2
		"D3D Shader Cache" = 0
		"Delivery Optimization Files" = 2
		"Diagnostic Data Viewer database files" = 2
		"Downloaded Program Files" = 2
		"Internet Cache Files" = 2
		"Language Pack" = 0
		"Old ChkDsk Files" = 2
		"Recycle Bin" = 0
		"RetailDemo Offline Content" = 2
		"Setup Log Files" = 2
		"System error memory dump files" = 2
		"System error minidump files" = 2
		"Temporary Files" = 0
		"Thumbnail Cache" = 2
		"Update Cleanup" = 2
		"User file versions" = 2
		"Windows Error Reporting Files" = 2
		"Windows Defender" = 2
		"Temporary Sync Files" = 2
		"Device Driver Packages" = 2
	}
	foreach ($entry in $regValues.GetEnumerator()) {
		$key = "$baseKey\$($entry.Key)"

		if (!(Test-Path $key)) {
			Write-Output "'$key' not found, not configuring it."
		} else {
			Set-ItemProperty -Path "$baseKey\$($entry.Key)" -Name 'StateFlags0064' -Value $entry.Value -Type DWORD
		}
	}
	Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:64" 2>&1 | Out-Null
}
$excludedDrive = "C"
$drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Name -ne $excludedDrive }
foreach ($drive in $drives) {
    if (!(Test-Path -Path $(Join-Path -Path $drive.Root -ChildPath 'Windows') -PathType Container)) {
        DiskClean
    }
}
$ErrorActionPreference = 'SilentlyContinue'
Get-ChildItem -Path "$env:TEMP" | Where-Object { $_.Name -ne 'AME' } | Remove-Item -Force -Recurse
Remove-Item -Path "$([Environment]::GetFolderPath('Windows'))\Temp\*" -Force -Recurse
vssadmin delete shadows /all /quiet
wevtutil el | ForEach-Object {wevtutil cl "$_"} 2>&1 | Out-Null
exit
}

Pop-Location
Remove-Item -Path $tempDir -Force -Recurse *>$null