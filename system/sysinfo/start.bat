@echo off
chcp 65001 >nul 2>&1
title SysInfo
setlocal

:menu
cls
echo СИСТЕМНАЯ ИНФОРМАЦИЯ:
echo ================================
echo 1 - Показать информацию о системе
echo 2 - Показать ключ Windows
echo 3 - Открыть папку с отчётами
echo 4 - Назад
choice /c 1234 /m "Выбор:"
if %errorlevel%==1 goto show
if %errorlevel%==2 goto key
if %errorlevel%==3 goto openReports
if %errorlevel%==4 goto back

:show
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sysinfo.ps1"
echo.
choice /c yn /n /m "Сохранить отчёт в файл? (y/n): "
if errorlevel 2 goto menu
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sysinfo.ps1" -Save
echo.
pause
goto menu

:key
cls
call "%~dp0key_view.bat"
goto menu

:openReports
if not exist "%~dp0reports" mkdir "%~dp0reports"
explorer "%~dp0reports"
goto menu

:back
cls
endlocal
exit /b 0