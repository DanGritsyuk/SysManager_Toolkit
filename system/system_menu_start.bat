cls
@echo off
chcp 65001 >nul 2>&1
:menu 
echo СИСТЕМНЫЕ УТИЛИТЫ:
echo ================================
echo 1 - Информация о системе
echo 2 - Проверка дисков
echo 3 - Очистка временных файлов
echo 0 - Назад
choice /c 1230 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto action2
if %errorlevel%==3 goto action3
if %errorlevel%==4 goto actionBack

:action1
call system/sysinfo/start.bat
goto menu

:action2
call system/disk_check/start.bat
goto menu

:action3
call system/temp_cleanup/start.bat
goto menu

:actionBack
cls
exit /b