@echo off
echo Запуск Flutter приложения...
cd /d "%~dp0"
flutter run -d web-server --web-port 3000
pause
