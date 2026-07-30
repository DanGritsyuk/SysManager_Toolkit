@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:menu
cls
echo ============================================
echo   УПРАВЛЕНИЕ ARP-ТАБЛИЦЕЙ
echo ============================================
echo.
echo 1 - Запустить сканирование (заполнение ARP)
echo 2 - Очистить ARP-таблицу
echo 3 - Открыть папку с таблицами
echo 4 - Назад
echo.
choice /c 1234 /m "Выбор:"
if %errorlevel%==1 goto scan
if %errorlevel%==2 goto clear_arp
if %errorlevel%==3 goto open_folder
if %errorlevel%==4 goto exit_script

:scan
call "%~dp0scan.bat"
goto menu

:clear_arp
call "%~dp0clear.bat"
goto menu

:open_folder
call "%~dp0open_folder.bat"
goto menu

:exit_script
cls
exit /b