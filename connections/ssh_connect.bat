@echo off
chcp 65001
setlocal enabledelayedexpansion

set "hostName=%~1"
set "login=%~2"
set "host=%~3"
set "port=%~4"

cls
echo "ВХОД В ${%hostName%^^}"
echo ================================
call ssh %login%@%host% -p %port%
chcp 65001
pause
cls
endlocal
exit /b