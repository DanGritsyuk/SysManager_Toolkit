@echo off
chcp 65001 >nul 2>&1
setlocal
cd /d "%~dp0.."

:menu
cls
echo СИСТЕМНЫЕ УТИЛИТЫ:
echo ================================
echo 1 - Информация о системе
echo 2 - Проверка дисков
echo 3 - Очистка временных файлов
echo 4 - Чтение огромных логов
echo 5 - Управление службами
echo 6 - Топ файлов/папок по размеру
echo 7 - Сбор диагностики (zip)
echo 0 - Назад
choice /c 12345670 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto action3
if %errorlevel%==4 goto action4
if %errorlevel%==5 goto action5
if %errorlevel%==6 goto action6
if %errorlevel%==7 goto action7
if %errorlevel%==8 goto actionBack

:action1
call "%~dp0sysinfo\start.bat"
goto menu
:action2
call "%~dp0disk_check\start.bat"
goto menu
:action3
call "%~dp0temp_cleanup\start.bat"
goto menu
:action4
call "%~dp0log_reader\start.bat"
goto menu
:action5
call "%~dp0service_manager\start.bat"
goto menu
:action6
call "%~dp0disk_top\start.bat"
goto menu
:action7
call "%~dp0collect\start.bat"
goto menu
:actionBack
cls
endlocal
exit /b