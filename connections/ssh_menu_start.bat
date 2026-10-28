@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:menu
cls
echo СПИСОК ПОДКЛЮЧЕНИЙ:
echo ================================

set "count=1"
for /f "usebackq tokens=1-4 delims=," %%a in ("connections\connections.txt") do (
    echo !count! - %%a
    set /a count+=1
)

set /a last_conn=!count!-1
echo 0 - Назад

choice /c 1234567890 /n /m "Выбор: "

if !errorlevel!==10 goto actionBack
if !errorlevel! gtr !last_conn! goto menu

set "line_num=!errorlevel!"

:: --- НАДЁЖНОЕ ИЗВЛЕЧЕНИЕ ПАРАМЕТРОВ ---
set "hostName="
set "login="
set "host="
set "port="
set "count=1"

for /f "usebackq tokens=1-4 delims=," %%a in ("connections\connections.txt") do (
    if !count! equ !line_num! (
        set "hostName=%%a"
        set "login=%%b"
        set "host=%%c"
        set "port=%%d"
    )
    set /a count+=1
)
:: --------------------------------------

goto start_ssh

:start_ssh
if "!hostName!"=="" (
    echo Ошибка: Не удалось прочитать данные подключения №!line_num!
    echo Проверьте connections.txt
    pause
    goto menu
)

echo ВХОД В: !hostName!
echo ================================
if not exist "connections\ssh_connect.bat" (
    echo Ошибка: Файл ssh_connect.bat не найден!
    pause
    goto menu
)

:: Передаем параметры в кавычках, чтобы пробелы не ломали аргументы
call connections\ssh_connect.bat "!hostName!" "!login!" "!host!" "!port!"

if !errorlevel! neq 0 (
    echo Ошибка подключения. Проверьте параметры.
) else (
    echo Подключение завершено.
)
pause
goto menu

:actionBack
cls
endlocal
exit /b 0