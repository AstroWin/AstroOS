for /f "usebackq" %%a in (`powershell -NonI -NoP -C "(Get-CimInstance Win32_NetworkAdapter).PNPDeviceID | sls 'PCI\\VEN_'"`) do (
	for /f "tokens=3" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%a" /v "Driver"') do ( 
        set "netKey=HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b"
    ) > nul 2>&1
)


for %%a in (
    "AutoDisableGigabit"
    "ApCompatMode"
    "SipsEnabled"
    "ReduceSpeedOnPowerDown"
    "DMACoalescing"
) do (
    rem
    for /f %%b in ('reg query "%netKey%" /v "%%~a" ^| findstr "HKEY"') do (
        reg add "%netKey%" /v "%%~a" /t REG_SZ /d "0" /f > nul
    )
    rem
    for /f %%b in ('reg query "%netKey%" /v "*%%~a" ^| findstr "HKEY"') do (
        reg add "%netKey%" /v "*%%~a" /t REG_SZ /d "0" /f > nul
    )
) > nul 2>&1

copy /y "Layout.xml" "!userAppdata!\Microsoft\Windows\Shell\LayoutModification.xml" > nul

			if "%%a" neq "AME_UserHive_Default" (
				echo Clear Start Menu pinned items
				for /f "usebackq delims=" %%d in (`dir /b "!userAppdata!\Packages" /a:d ^| findstr /c:"Microsoft.Windows.StartMenuExperienceHost"`) do (
					for /f "usebackq delims=" %%e in (`dir /b "!userAppdata!\Packages\%%d\LocalState" /a:-d ^| findstr /R /c:"start.\.bin" /c:"start\.bin"`) do (
						del /q /f "!userAppdata!\Packages\%%d\LocalState\%%e" > nul 2>&1
					)
				)
			)

for /f "usebackq delims=" %%c in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" 2^>nul ^| findstr /c:"start.tilegrid" 2^>nul`) do (
			reg delete "%%c" /f > nul 2>&1
		)
		
		echo Removing advertisements/stubs from Start Menu ^(23H2+^)
		reg delete "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" /v "Config" /f > nul 2>&1            

exit /b