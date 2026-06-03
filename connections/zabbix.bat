@echo off
setlocal enabledelayedexpansion

set "login=root"
set "host=you.host"
set "port=22"

cls
echo ‚•Ž„ ‚ ZABBIX
echo ================================
call ssh %login%@%host% -p %port%
chcp 866
cls
exit /b