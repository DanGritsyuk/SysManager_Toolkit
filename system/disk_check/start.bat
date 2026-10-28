@echo off
chcp 65001 >nul 2>&1
title Disk Check
setlocal

:menu
cls
echo ПРОВЕРКА ДИСКОВ:
echo ================================
echo 1 - Показать состояние дисков
echo 2 - Сохранить отчёт в файл
echo 3 - Открыть папку с отчётами
echo 0 - Назад
choice /c 1230 /m "Выбор:"
if %errorlevel%==1 goto show
if %errorlevel%==2 goto save
if %errorlevel%==3 goto openReports
if %errorlevel%==4 goto back

:show
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_check.ps1"
echo.
pause
goto menu

:save
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0disk_check.ps1" -Save
echo.
pause
goto menu

:openReports
if not exist "%~dp0reports" mkdir "%~dp0reports"
explorer "%~dp0reports"
goto menu

:back
cls
endlocal
exit /b 0