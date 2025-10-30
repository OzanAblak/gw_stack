@echo off
rem Delegate to PowerShell script to avoid planId/TTL races
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ci_smoke_gwfwd.ps1"
exit /b 0
