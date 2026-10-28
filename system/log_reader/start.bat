@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
title Log Reader

set "TARGET_FILE=%~1"
set "ENC=UTF8"

:check_file
cls
if defined TARGET_FILE (
    for /f "tokens=*" %%A in ("!TARGET_FILE!") do set "TARGET_FILE=%%~fA"
    if exist "!TARGET_FILE!" goto menu
    echo.
    echo [ОШИБКА] Файл не найден или это папка:
    echo !TARGET_FILE!
    echo.
    set "TARGET_FILE="
)

echo ВВЕДИТЕ ПУТЬ К ФАЙЛУ:
echo (или перетащите файл прямо в это окно)
echo (оставьте пустым и нажмите Enter для выхода)
echo.
set /p "TARGET_FILE=Путь: "
if not defined TARGET_FILE exit /b
goto check_file

:menu
cls
echo ==========================================================
echo  ЛОГ-РИДЕР: !TARGET_FILE!
echo  Кодировка: !ENC!
echo ==========================================================
echo  1 - Прочитать НАЧАЛО файла (первые 50 строк)
echo  2 - Прочитать КОНЕЦ файла (последние 100 строк)
echo  3 - ЖИВОЙ ХВОСТ (следить за обновлениями в реальном времени)
echo  4 - ПОИСК по ключевому слову
echo  5 - ПОСТРАНИЧНЫЙ просмотр (весь файл)
echo  6 - Сменить файл
echo  7 - Сменить кодировку (текущая: !ENC!)
echo  0 - Назад (в главное меню)
echo ==========================================================
choice /c 12345670 /n /m "Выбор: "

if errorlevel 8 goto actionBack
if errorlevel 7 goto change_encoding
if errorlevel 6 goto change_file
if errorlevel 5 goto page
if errorlevel 4 goto search
if errorlevel 3 goto live
if errorlevel 2 goto tail
if errorlevel 1 goto head

:head
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Head -Lines 50 -Encoding "!ENC!"
echo.
pause
goto menu

:tail
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Tail -Lines 100 -Encoding "!ENC!"
echo.
pause
goto menu

:live
cls
echo ВНИМАНИЕ: Нажмите Ctrl+C, чтобы остановить слежение и вернуться в меню.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Live -Lines 20 -Encoding "!ENC!"
echo.
pause
goto menu

:search
cls
set "TERM="
set /p "TERM=Введите слово или регулярное выражение для поиска: "
if not defined TERM goto menu
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Search -SearchTerm "!TERM!" -Encoding "!ENC!"
echo.
pause
goto menu

:page
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Page -Encoding "!ENC!"
echo.
pause
goto menu

:change_file
set "TARGET_FILE="
goto check_file

:change_encoding
cls
echo ТЕКУЩАЯ КОДИРОВКА: !ENC!
echo ================================
echo  1 - UTF8   (современные логи, .log из Linux/DevOps)
echo  2 - Default (ANSI / системная кодировка Windows)
echo  3 - 1251   (Windows-1251, старые русские логи)
echo  0 - Отмена
choice /c 1230 /n /m "Выбор: "
if errorlevel 4 goto menu
if errorlevel 3 set "ENC=Windows-1251" & goto menu
if errorlevel 2 set "ENC=Default" & goto menu
if errorlevel 1 set "ENC=UTF8" & goto menu
goto menu

:actionBack
cls
endlocal
exit /b 0