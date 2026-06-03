@echo off
setlocal

:: Настройки
set LOGFILE=network\internet_watch\log\internet_check.log
set INTERNET_CHECK_HOST=ya.ru
set ROUTER_HOST=router.host

:menu
cls
echo ПРОВЕРКА ИНТЕРНЕТА:
echo ================================
echo 1 - Запустить проверку
echo 2 - Открыть лог-файл
echo 3 - Выход
choice /c 123 /m "Выбор:"
if %errorlevel%==1 goto check_connection
if %errorlevel%==2 goto open_log
if %errorlevel%==3 goto exit_script

:check_connection
cls
echo.
echo Запуск проверки интернет-соединения...
echo.
call network\internet_watch\check_connection.bat %LOGFILE% %INTERNET_CHECK_HOST% %ROUTER_HOST%
echo.
pause
goto menu

:open_log
cls
echo.
if exist "%LOGFILE%" (
    start notepad.exe "%LOGFILE%"
    echo Лог-файл открыт в Notepad.
) else (
    echo ОШИБКА: Лог-файл не найден: %LOGFILE%
)
echo.
pause
goto menu

:exit_script
cls
echo.
echo Выход из скрипта. До свидания!
timeout /t 2 >nul
cls
exit /b
