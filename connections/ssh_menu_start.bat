@echo off
setlocal enabledelayedexpansion

cls
:menu 
echo ‘ˆ‘Š „Š‹—…ˆ‰:
echo ================================
echo 1 - Connection1
echo 3 -  § ¤
choice /c 12 /m "‚ë¡®à:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto actionBack

:add_new
call connections/new.bat
goto menu

:action1
set "hostName=Connection1"
set "login=root"
set "host=connection1.host"
set "port=22"
goto start_ssh

:start_ssh
call connections/ssh_connect.bat %hostName% %login% %host% %port% 
goto menu

:actionBack
cls
endlocal
exit /b