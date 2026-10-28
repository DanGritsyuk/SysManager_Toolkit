cls
@echo off
:menu 
echo ВЫБОР СЦЕНАРИЯ:
echo ================================
echo 1 - SSH подключения
echo 2 - Сценарии сети
echo 3 - Системные утилиты
echo 0 - Выход
choice /c 1230 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto action3
if %errorlevel%==4 goto exit

:action1
call connections/ssh_menu_start.bat
goto menu

:action2
call network/net_menu_start.bat
goto menu

:action3
call system/system_menu_start.bat
goto menu

:exit
cls
echo Выход...
timeout /t 1 >nul