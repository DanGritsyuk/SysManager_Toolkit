@echo off
chcp 65001 >nul 2>&1
title Temp Cleanup
setlocal

:menu
cls
echo ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ
echo ================================
echo 1 - Анализ (dry-run, ничего не удаляет)
echo 2 - Очистка (с подтверждением)
echo 3 - DISM: очистка Component Store
echo 4 - Расширенная очистка (+ Prefetch + кэши браузеров)
echo 0 - Назад
choice /c 12340 /n /m "Выбор: "
if errorlevel 5 goto back
if errorlevel 4 goto extended
if errorlevel 3 goto dism
if errorlevel 2 goto clean
if errorlevel 1 goto analyze

:analyze
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0temp_cleanup.ps1" -DryRun
echo.
pause
goto menu

:clean
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0temp_cleanup.ps1" -Clean
echo.
pause
goto menu

:dism
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0temp_cleanup.ps1" -Dism
echo.
pause
goto menu

:extended
cls
echo Сначала анализ с Prefetch и кэшами браузеров...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0temp_cleanup.ps1" -DryRun -IncludePrefetch -IncludeBrowserCache
echo.
choice /c yn /n /m "Выполнить очистку с этими параметрами? (y/n): "
if errorlevel 2 goto menu
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0temp_cleanup.ps1" -Clean -IncludePrefetch -IncludeBrowserCache
echo.
pause
goto menu

:back
cls
endlocal
exit /b 0