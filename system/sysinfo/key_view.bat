@echo off
chcp 65001 >nul 2>&1
title Windows Key Viewer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0key_view.ps1"
echo.
pause
exit /b 0