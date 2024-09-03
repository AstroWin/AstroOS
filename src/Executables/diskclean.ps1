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