@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
title Log Reader

set "TARGET_FILE=%~1"

:check_file
if defined TARGET_FILE (
    :: Убираем кавычки (если перетащили файл) и лишние пробелы
    for /f "tokens=*" %%A in ("!TARGET_FILE!") do set "TARGET_FILE=%%~fA"
    
    :: Проверяем, существует ли файл
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
echo ==========================================================
echo  1 - Прочитать НАЧАЛО файла (первые 50 строк)
echo  2 - Прочитать КОНЕЦ файла (последние 100 строк)
echo  3 - ЖИВОЙ ХВОСТ (следить за обновлениями в реальном времени)
echo  4 - ПОИСК по ключевому слову
echo  5 - ПОСТРАНИЧНЫЙ просмотр (весь файл)
echo  6 - Сменить файл
echo  0 - Назад (в главное меню)
echo ==========================================================
choice /c 1234560 /n /m "Выбор: "

if errorlevel 7 goto actionBack
if errorlevel 6 goto change_file
if errorlevel 5 goto page
if errorlevel 4 goto search
if errorlevel 3 goto live
if errorlevel 2 goto tail
if errorlevel 1 goto head

:head
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Head -Lines 50
echo.
pause
goto menu

:tail
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Tail -Lines 100
echo.
pause
goto menu

:live
cls
echo ВНИМАНИЕ: Нажмите Ctrl+C, чтобы остановить слежение и вернуться в меню.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Live -Lines 20
echo.
pause
goto menu

:search
cls
set "TERM="
set /p "TERM=Введите слово или регулярное выражение для поиска: "
if not defined TERM goto menu
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Search -SearchTerm "!TERM!"
echo.
pause
goto menu

:page
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0log_reader.ps1" -FilePath "!TARGET_FILE!" -Action Page
echo.
pause
goto menu

:change_file
set "TARGET_FILE="
goto check_file

:actionBack
cls
endlocal
exit /b 0