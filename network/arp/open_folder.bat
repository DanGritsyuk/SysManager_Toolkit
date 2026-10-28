@echo off
chcp 65001 >nul
setlocal

:: Папка tables находится в той же директории, что и скрипт
set "TABLE_DIR=%~dp0tables"

:: Если папки нет – создаём
if not exist "%TABLE_DIR%" mkdir "%TABLE_DIR%"

:: Открываем папку в Проводнике
start explorer "%TABLE_DIR%"

exit /b