cls
@echo off
:menu 
echo СПИСОК СКРИПТОВ:
echo ================================
echo 1 - Проверка Интернета
echo 2 - Назад
choice /c 12 /m "Выбор:"
if %errorlevel%==1 goto action1
if %errorlevel%==2 goto actionBack

:action1
call network/internet_watch/start.bat
goto menu

:actionBack
cls
exit /b