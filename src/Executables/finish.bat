@echo off
shutdown /r /t 10 /c "AstroOS Installation Completed Sucessfully. Your PC will restart soon.
timeout /t 3 /nobreak >nul
taskkill /F /IM "AME Wizard.exe" /T >nul 2>&1