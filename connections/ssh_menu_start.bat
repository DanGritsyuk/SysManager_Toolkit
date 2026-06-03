@echo off
cls
:menu 
echo СПИСОК ПОДКЛЮЧЕНИЙ:
echo ================================
echo 1 - Zabbix
echo 2 - Назад
choice /c 12 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto actionBack

:action1
call connections/zabbix.bat
goto menu

:actionBack
cls
exit /b