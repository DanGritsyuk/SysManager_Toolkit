@echo off
chcp 65001 >nul 2>&1
cls
:menu 
echo СПИСОК СКРИПТОВ:
echo ================================
echo 1 - Проверка Интернета
echo 2 - ARP-таблица
echo 0 - Назад
choice /c 120 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto actionBack

:action1
call network/internet_watch/start.bat
goto menu

:action2
call network/arp/start.bat
goto menu

:actionBack
cls
exit /b