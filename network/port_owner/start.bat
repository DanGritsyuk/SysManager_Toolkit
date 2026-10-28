@echo off
chcp 65001 >nul 2>&1
title Port Owner
setlocal enabledelayedexpansion
:menu
cls
echo ПОРТЫ И ПРОЦЕССЫ
echo ================================
echo 1 - Список слушающих портов
echo 2 - Найти процесс по порту
echo 3 - Найти порты по процессу
echo 0 - Назад
choice /c 1230 /n /m "Выбор: "
if errorlevel 4 goto back
if errorlevel 3 goto byproc
if errorlevel 2 goto byport
if errorlevel 1 goto list

:list
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0port_owner.ps1" -List
pause
goto menu
:byport
cls
set /p "P=Введите порт: "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0port_owner.ps1" -Port !P!
pause
goto menu
:byproc
cls
set /p "P=Введите имя процесса (часть): "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0port_owner.ps1" -Process "!P!"
pause
goto menu
:back
cls
endlocal
exit /b 0