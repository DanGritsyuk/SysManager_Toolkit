@echo off
setlocal

:: Получение параметров из основного скрипта
set LOGFILE=%1
set INTERNET_CHECK_HOST=%2
set ROUTER_HOST=%3

:: Запись в лог
powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Проверка интернет-соединения') -Encoding UTF8"

:: Проверка интернет-соединения
ping -n 1 %INTERNET_CHECK_HOST% >nul
if %errorlevel% == 0 (
    echo [ОК] Интернет-соединение доступно.
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Интернет-соединение доступно.') -Encoding UTF8"
) else (
    echo [ОШИБКА] Интернет-соединение отсутствует. Проверяю роутер...
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Интернет-соединение отсутствует. Проверяю доступность роутера...') -Encoding UTF8"
    
    :: Проверка роутера
    ping -n 1 %ROUTER_HOST% >nul
    if %errorlevel% == 0 (
        echo [ВНИМАНИЕ] Роутер доступен, но интернет отсутствует.
        powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Роутер доступен, но интернет-соединение отсутствует.') -Encoding UTF8"
    ) else (
        echo [КРИТИЧНО] Роутер недоступен. Перезапускаю сессию...
        powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Роутер недоступен. Перезапускаю сессию...') -Encoding UTF8"
    )
    
    echo Выполнение команд восстановления сети...
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Выполняю команды ipconfig /release, /flushdns, /renew...') -Encoding UTF8"
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('---------------------') -Encoding UTF8"
    
    chcp 65001
    ipconfig /release >> %LOGFILE% 2>&1
    ipconfig /flushdns >> %LOGFILE% 2>&1
    ipconfig /renew >> %LOGFILE% 2>&1
    chcp 866
    
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('---------------------') -Encoding UTF8"
    echo [ЗАВЕРШЕНО] Команды восстановления выполнены.
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Команды выполнены.') -Encoding UTF8"
)

powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('') -Encoding UTF8"
endlocal
exit /b
