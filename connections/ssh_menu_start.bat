@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
cd /d "%~dp0.."

:menu
cls
echo СПИСОК ПОДКЛЮЧЕНИЙ:
echo ================================
set "count=0"
for /f "usebackq tokens=1-4 delims=," %%a in ("connections\connections.txt") do (
    set /a count+=1
    echo !count! - %%a
)
if !count! equ 0 (
    echo Нет подключений. Добавьте строки в connections\connections.txt
    pause
    exit /b
)
echo 0 - Назад
echo.
set /p "choice=Выбор: "
if "!choice!"=="0" goto actionBack
set /a num=!choice! 2>nul
if !num! lss 1 goto menu
if !num! gtr !count! goto menu

set "line_num=!num!"
set "hostName=" & set "login=" & set "host=" & set "port="
set "c=0"
for /f "usebackq tokens=1-4 delims=," %%a in ("connections\connections.txt") do (
    set /a c+=1
    if !c! equ !line_num! (
        set "hostName=%%a"
        set "login=%%b"
        set "host=%%c"
        set "port=%%d"
    )
)
if "!hostName!"=="" (
    echo Ошибка: не удалось прочитать данные подключения.
    pause
    goto menu
)
call "%~dp0ssh_connect.bat" "!hostName!" "!login!" "!host!" "!port!"
pause
goto menu

:actionBack
cls
endlocal
exit /b 0