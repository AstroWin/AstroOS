param (
	[switch]$Brave,
	[switch]$Firefox,
	[switch]$Thorium,
	[switch]$Ui,
	[switch]$Defender,
	[switch]$Sab,
	[switch]$Diskclean
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