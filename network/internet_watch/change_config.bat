@echo off
setlocal enabledelayedexpansion
chcp 65001
cls

set "CONFIG_FILE=%~1"

:: Читаем текущие значения при запуске
:read_current
for /f "usebackq tokens=1,2 delims==" %%i in ("%CONFIG_FILE%") do (
    if "%%i"=="INTERNET_CHECK_HOST" set "CURRENT_INTERNET=%%j"
    if "%%i"=="ROUTER_HOST" set "CURRENT_ROUTER=%%j"
)

:: Главное меню с текущими значениями в заголовке
:menu
cls
echo НАСТРОЙКИ СЕТИ
echo ================================
echo Текущие значения:
echo   INTERNET_CHECK_HOST = !CURRENT_INTERNET!
echo   ROUTER_HOST = !CURRENT_ROUTER!
echo.
echo ЧТО ИЗМЕНИТЬ?
echo --------------------------------
echo 1 - INTERNET_CHECK_HOST
echo 2 - ROUTER_HOST
echo 3 - Оба параметра
echo 0 - Выход
choice /c 1230 /m "Выбор:"
if %errorlevel%==1 goto change_internet
if %errorlevel%==2 goto change_router
if %errorlevel%==3 goto change_both
if %errorlevel%==4 goto exit

:: Изменение INTERNET_CHECK_HOST
:change_internet
cls
echo ТЕКУЩЕЕ ЗНАЧЕНИЕ: INTERNET_CHECK_HOST = !CURRENT_INTERNET!
echo.
set /p NEW_INTERNET="Введите новое значение для INTERNET_CHECK_HOST: "
call :update_ini "INTERNET_CHECK_HOST" "%NEW_INTERNET%"
set "CURRENT_INTERNET=%NEW_INTERNET%"
echo Значение INTERNET_CHECK_HOST обновлено на: %NEW_INTERNET%
timeout /t 2 >nul
goto menu

:: Изменение ROUTER_HOST
:change_router
cls
echo ТЕКУЩЕЕ ЗНАЧЕНИЕ: ROUTER_HOST = !CURRENT_ROUTER!
echo.
set /p NEW_ROUTER="Введите новое значение для ROUTER_HOST: "
call :update_ini "ROUTER_HOST" "%NEW_ROUTER%"
set "CURRENT_ROUTER=%NEW_ROUTER%"
echo Значение ROUTER_HOST обновлено на: %NEW_ROUTER%
timeout /t 2 >nul
goto menu

:: Изменение обоих параметров
:change_both
cls
echo ТЕКУЩИЕ ЗНАЧЕНИЯ:
echo   INTERNET_CHECK_HOST = !CURRENT_INTERNET!
echo   ROUTER_HOST = !CURRENT_ROUTER!
echo.
set /p NEW_INTERNET="Введите новое значение для INTERNET_CHECK_HOST: "
set /p NEW_ROUTER="Введите новое значение для ROUTER_HOST: "
call :update_ini "INTERNET_CHECK_HOST" "%NEW_INTERNET%"
call :update_ini "ROUTER_HOST" "%NEW_ROUTER%"
set "CURRENT_INTERNET=%NEW_INTERNET%"
set "CURRENT_ROUTER=%NEW_ROUTER%"
echo Значения обновлены:
echo   INTERNET_CHECK_HOST = %NEW_INTERNET%
echo   ROUTER_HOST = %NEW_ROUTER%
timeout /t 2 >nul
goto menu

:: Функция обновления INI-файла
:update_ini
set "KEY=%~1"
set "VALUE=%~2"

(for /f "usebackq delims=" %%a in ("%CONFIG_FILE%") do (
    set "line=%%a"
    if "!line:~0,1!"=="[" (
        echo(!line!
    ) else (
        for /f "tokens=1,* delims==" %%b in ("!line!") do (
            if "%%b"=="%KEY%" (
                echo %KEY%=%VALUE%
            ) else (
                echo(!line!
            )
        )
    )
)) > "%CONFIG_FILE%.tmp"

move /y "%CONFIG_FILE%.tmp" "%CONFIG_FILE%" >nul
goto :eof

:: Выход из скрипта
:exit
cls
endlocal
exit /b
