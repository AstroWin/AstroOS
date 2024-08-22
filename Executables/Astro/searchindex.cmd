@echo off
setlocal EnableDelayedExpansion
sc config WSearch start=disabled > nul
sc stop WSearch > nul 2>&1
exit /b