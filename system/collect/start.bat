@echo off
chcp 65001 >nul 2>&1
title Collect Bundle
cls
echo СБОР ДИАГНОСТИКИ
echo ================================
echo Будет собран zip: systeminfo, ipconfig, route, arp, порты,
echo службы, процессы, диски, последние события.
echo.
pause
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0collect.ps1"
echo.
pause
exit /b 0