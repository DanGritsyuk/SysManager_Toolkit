@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
title SysManager Toolkit

:: CWD = папка скрипта, независимо от способа запуска (в т.ч. Elevated)
cd /d "%~dp0"

set "ADMIN_FLAG=[USER]"
net session >nul 2>&1 && set "ADMIN_FLAG=[ADMIN]"

:menu
cls
echo ============================================
echo   SysManager Toolkit
echo   %ADMIN_FLAG% %COMPUTERNAME% \ %USERDOMAIN% \ %USERNAME%
echo ============================================
echo.
echo 1 - SSH подключения
echo 2 - Сценарии сети
echo 3 - Системные утилиты
echo 4 - Проверка окружения
echo 5 - Поиск команды
echo 0 - Выход
echo.
choice /c 123450 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto action3
if %errorlevel%==4 goto doctor
if %errorlevel%==5 goto search
if %errorlevel%==6 goto exit

:action1
call "%~dp0connections\ssh_menu_start.bat"
goto menu
:action2
call "%~dp0network\net_menu_start.bat"
goto menu
:action3
call "%~dp0system\system_menu_start.bat"
goto menu
:doctor
call "%~dp0doctor.bat"
goto menu
:search
cls
set "TERM="
set /p "TERM=Введите ключевое слово (ssh, net, disk, log, service, port, collect): "
if not defined TERM goto menu
cls
echo Результаты по запросу "%TERM%":
echo.
echo   connections\ssh_menu_start.bat   - SSH подключения
echo   network\net_menu_start.bat        - Сеть (интернет, ARP)
echo   network\port_owner\start.bat      - Порты и процессы
echo   system\sysinfo\start.bat          - Информация о системе
echo   system\disk_check\start.bat       - Проверка дисков
echo   system\disk_top\start.bat         - Топ файлов/папок по размеру
echo   system\temp_cleanup\start.bat     - Очистка временных файлов
echo   system\log_reader\start.bat       - Чтение логов
echo   system\service_manager\start.bat  - Управление службами
echo   system\collect\start.bat          - Сбор диагностики в zip
echo   doctor.bat                        - Проверка окружения
echo.
pause
goto menu
:exit
cls
echo Выход...
timeout /t 1 >nul
endlocal
exit /b 0