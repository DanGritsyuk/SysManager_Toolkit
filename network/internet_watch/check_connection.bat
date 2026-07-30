@echo off
setlocal
chcp 65001
cls

:: Получение параметров из основного скрипта
set "LOGFILE=%~1"
set "INTERNET_CHECK_HOST=%~2"
set "ROUTER_HOST=%~3"

:: Проверка корректности входных параметров
if not defined LOGFILE (
    echo [ОШИБКА] Не указан файл лога. Завершение работы.
    exit /b 1
)
if not defined INTERNET_CHECK_HOST (
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% ОШИБКА: Не указан хост для проверки интернет-соединения.') -Encoding UTF8"
    echo [ОШИБКА] Не указан хост для проверки интернет-соединения. Завершение работы.
    exit /b 1
)
if not defined ROUTER_HOST (
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% ОШИБКА: Не указан адрес роутера.') -Encoding UTF8"
    echo [ОШИБКА] Не указан адрес роутера. Завершение работы.
    exit /b 1
)

:: Проверка доступности файла лога для записи
>nul 2>&1 (
    (call )
) || (
    echo [ОШИБКА] Нет доступа для записи в файл лога: %LOGFILE%
    exit /b 1
)

:: Запись в лог начала выполнения
powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Проверка интернет-соединения') -Encoding UTF8" 2>nul
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Не удалось записать в лог. Продолжаю выполнение...
)

:: Проверка интернет-соединения
ping -n 1 "%INTERNET_CHECK_HOST%" >nul 2>nul
if %errorlevel% == 0 (
    echo [ОК] Интернет-соединение доступно.
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Интернет-соединение доступно.') -Encoding UTF8" 2>nul
) else (
    echo [ОШИБКА] Интернет-соединение отсутствует. Проверяю роутер...
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Интернет-соединение отсутствует. Проверяю доступность роутера...') -Encoding UTF8" 2>nul

    :: Проверка роутера
    ping -n 1 "%ROUTER_HOST%" >nul 2>nul
    if %errorlevel% == 0 (
        echo [ВНИМАНИЕ] Роутер доступен, но интернет отсутствует.
        powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Роутер доступен, но интернет-соединение отсутствует.') -Encoding UTF8" 2>nul
    ) else (
        echo [КРИТИЧНО] Роутер недоступен. Перезапускаю сессию...
        powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Роутер недоступен. Перезапускаю сессию...') -Encoding UTF8" 2>nul
    )

    echo Выполнение команд восстановления сети...
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Выполняю команды ipconfig /release, /flushdns, /renew...') -Encoding UTF8" 2>nul
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('---------------------') -Encoding UTF8" 2>nul

    chcp 65001 >nul
    ipconfig /release >> "%LOGFILE%" 2>> "%LOGFILE%"
    ipconfig /flushdns >> "%LOGFILE%" 2>> "%LOGFILE%"
    ipconfig /renew >> "%LOGFILE%" 2>> "%LOGFILE%"
    chcp 866 >nul

    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('---------------------') -Encoding UTF8" 2>nul
    echo [ЗАВЕРШЕНО] Команды восстановления выполнены.
    powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('%date% %time% Команды выполнены.') -Encoding UTF8" 2>nul
)

powershell -Command "Add-Content -Path '%LOGFILE%' -Value ('') -Encoding UTF8" 2>nul
endlocal
exit /b
