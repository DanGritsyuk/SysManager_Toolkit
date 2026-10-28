@echo off
chcp 65001 >nul 2>&1
title Disk Top
setlocal enabledelayedexpansion
:menu
cls
echo ТОП ФАЙЛОВ И ПАПОК ПО РАЗМЕРУ
echo ================================
echo 1 - Топ файлов (C:\)
echo 2 - Топ папок (C:\)
echo 3 - Указать путь
echo 0 - Назад
choice /c 1230 /n /m "Выбор: "
if errorlevel 4 goto back
if errorlevel 3 goto custom
if errorlevel 2 goto folders
if errorlevel 1 goto files

:files
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_top.ps1" -Path "C:\" -Top 20
pause
goto menu
:folders
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_top.ps1" -Path "C:\" -Top 20 -Folders
pause
goto menu
:custom
cls
set /p "P=Путь (например D:\Logs): "
set /p "T=Сколько показать (Enter — 20): "
if "!T!"=="" set "T=20"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_top.ps1" -Path "!P!" -Top !T!
pause
goto menu
:back
cls
endlocal
exit /b 0