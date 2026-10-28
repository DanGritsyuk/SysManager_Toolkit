@echo off
chcp 65001 >nul 2>&1
title Service Manager
setlocal enabledelayedexpansion
:menu
cls
echo УПРАВЛЕНИЕ СЛУЖБАМИ
echo ================================
echo 1 - Список служб (с фильтром)
echo 2 - Перезапустить службу
echo 3 - Зависимости службы
echo 4 - Службы с автозапуском
echo 0 - Назад
choice /c 12340 /n /m "Выбор: "
if errorlevel 5 goto back
if errorlevel 4 goto autostart
if errorlevel 3 goto deps
if errorlevel 2 goto restart
if errorlevel 1 goto list

:list
cls
set /p "F=Фильтр (часть имени, Enter — все): "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0service_manager.ps1" -Action list -Filter "!F!"
pause
goto menu
:restart
cls
set /p "N=Имя службы для перезапуска: "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0service_manager.ps1" -Action restart -Name "!N!"
pause
goto menu
:deps
cls
set /p "N=Имя службы: "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0service_manager.ps1" -Action deps -Name "!N!"
pause
goto menu
:autostart
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0service_manager.ps1" -Action autostart
pause
goto menu
:back
cls
endlocal
exit /b 0