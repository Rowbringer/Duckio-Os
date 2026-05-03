@echo off
REM Duckio OS post-install hook template
REM Copy this file to C:\Windows\Setup\Scripts\SetupComplete.cmd if you want auto-run.

if not exist C:\duckio exit /b 0
powershell -ExecutionPolicy Bypass -File C:\duckio\duckio-setup.ps1 -SkipApps
exit /b %errorlevel%
