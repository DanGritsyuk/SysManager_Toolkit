@echo off
chcp 65001 >nul 2>&1
title Doctor
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0doctor.ps1"
echo.
pause
exit /b 0