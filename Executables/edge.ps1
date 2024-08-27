$fileUrl = "https://github.com/ShadowWhisperer/Remove-MS-Edge/raw/main/Remove-NoTerm.exe"
$tempPath = [System.IO.Path]::GetTempPath()
$destinationPath = Join-Path -Path $tempPath -ChildPath "Remove-NoTerm.exe"
Invoke-WebRequest -Uri $fileUrl -OutFile $destinationPath
Start-Process -FilePath $destinationPath -NoNewWindow -Wait