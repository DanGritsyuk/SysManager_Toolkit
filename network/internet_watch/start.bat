@echo off
setlocal enabledelayedexpansion
chcp 65001
cls
set INI_FILE=network\internet_watch\config.ini

:: Читаем настройки из config.ini
for /f "tokens=1,2 delims==" %%a in ('findstr /b /l "LOGFILE= INTERNET_CHECK_HOST= ROUTER_HOST=" "%INI_FILE%"') do (
    set %%a=%%b
)

:menu
cls
echo ПРОВЕРКА ИНТЕРНЕТА:
echo ================================
echo 1 - Запустить проверку
echo 2 - Открыть лог-файл
echo 3 - Изменить настройки
echo 4 - Выход
choice /c 1234 /m "Выбор:"
if %errorlevel%==1 goto check_connection
if %errorlevel%==2 goto open_log
if %errorlevel%==3 goto change_config
if %errorlevel%==4 goto exit_script

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

:change_config
cls
call network\internet_watch\change_config.bat %INI_FILE%
echo.
goto menu

:exit_script
cls
echo.
echo Выход из скрипта. До свидания!
timeout /t 2 >nul
cls
endlocal
exit /b

:read_ini
set "INI_FILE=%~1"
set "SECTION=%~2"
for /f "usebackq tokens=1,2 delims==" %%A in (`findstr /b "%SECTION%" "%INI_FILE%"`) do (
    if "%%A"=="%SECTION%" (
        for /f "eol=; tokens=1,2 delims==" %%X in ('findstr /b /c:"%%B" "%INI_FILE%"') do (
            set "%%X=%%Y"
        )
    )
)
goto :eof