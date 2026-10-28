@echo off
chcp 65001 >nul 2>&1
setlocal
cd /d "%~dp0.."

:menu
cls
echo СЕТЕВЫЕ СЦЕНАРИИ:
echo ================================
echo 1 - Проверка Интернета
echo 2 - ARP-таблица
echo 3 - Порты и процессы (Port Owner)
echo 0 - Назад
choice /c 1230 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto action3
if %errorlevel%==4 goto actionBack

:action1
call "%~dp0internet_watch\start.bat"
goto menu
:action2
call "%~dp0arp\start.bat"
goto menu
:action3
call "%~dp0port_owner\start.bat"
goto menu
:actionBack
cls
endlocal
exit /b