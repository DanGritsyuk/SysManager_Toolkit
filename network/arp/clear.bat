@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cls
echo ============================================
echo   ОЧИСТКА ARP-ТАБЛИЦЫ
echo ============================================
echo.

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Для очистки ARP-таблицы требуются права администратора.
    echo Запустите скрипт от имени администратора.
    echo.
    pause
    exit /b
)

echo Выполняется очистка ARP-кэша...
arp -d * 2>nul
netsh interface ip delete arpcache >nul 2>&1
echo Готово.
echo.
pause
exit /b