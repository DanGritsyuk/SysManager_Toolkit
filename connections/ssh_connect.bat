@echo off
setlocal enabledelayedexpansion

set "hostName=%~1"
set "login=%~2"
set "host=%~3"
set "port=%~4"

cls
echo "‚•Ž„ ‚ ${%hostName%^^}"
echo ================================
call ssh %login%@%host% -p %port%
chcp 866
pause
cls
endlocal
exit /b