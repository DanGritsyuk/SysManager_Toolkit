@echo off
setlocal enabledelayedexpansion

:menu
cls
echo СПИСОК ПОДКЛЮЧЕНИЙ:
echo ================================

:: Читаем файл подключений и строим меню
set "count=1"
for /f "usebackq tokens=1-4 delims=," %%a in ("connections\connections.txt") do (
    call :print_line %%a
    set /a count+=1
)
set /a back_option=%count%
echo %back_option% - Назад

choice /c 1234567890 /n /m "Выбор: "
if %errorlevel%==%back_option% goto actionBack
if %errorlevel% gtr %back_option% goto menu

:: Извлекаем параметры выбранного подключения
set "line_num=%errorlevel%"

:: Используем временный файл для надёжности
set "temp_file=%temp%\connections_temp.txt"
findstr /n . "connections\connections.txt" > "%temp_file%"

for /f "tokens=1-5 delims=:," %%i in ('findstr "^%line_num%:" "%temp_file%"') do (
    set "hostName=%%j"
    set "login=%%k"
    set "host=%%l"
    set "port=%%m"
)

del "%temp_file%" 2>nul

goto start_ssh

:start_ssh
echo Подключение к: !hostName! (!host!:!port!, пользователь: !login!)
if not exist "connections\ssh_connect.bat" (
    echo Ошибка: Файл ssh_connect.bat не найден!
    pause
    goto menu
)
call connections/ssh_connect.bat !hostName! !login! !host! !port!
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
exit /b

:print_line
echo %count% - %1
goto :eof
