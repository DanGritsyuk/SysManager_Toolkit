@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cls
echo ============================================
echo   ОЧИСТКА ARP-ТАБЛИЦЫ
echo ============================================
echo.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Требуются права администратора.
    pause
    exit /b 1
)
echo Это действие очистит ARP-кэш. Продолжить? (y/n)
choice /c yn /n
if errorlevel 2 exit /b 0
echo Выполняется очистка...
arp -d * 2>nul
netsh interface ip delete arpcache >nul 2>&1
echo Готово.
pause
exit /b 0