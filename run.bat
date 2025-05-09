@echo off
echo Dang khoi dong Chatbot TVTS...

set frontend_npm_pid=
set backend_py_pid=

:start_frontend
echo Dang khoi dong frontend...
cd frontend || (
    echo LOI: Khong the cd den frontend. Dang huy bo.
    exit /b 1
)
start /b npm run dev
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq node.exe" /fo list /v ^| find /i "NPM"') do set frontend_npm_pid=%%a
cd ..
echo Frontend (npm run dev) da duoc khoi dong voi PID %frontend_npm_pid%

:start_backend
echo Dang khoi dong backend...
cd backend || (
    echo LOI: Khong the cd den backend. Dang huy bo.
    exit /b 1
)
start /b python -m app.main
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq python.exe" /fo list /v ^| find /i "app.main"') do set backend_py_pid=%%a
cd ..
echo Backend (python -m app.main) da duoc khoi dong voi PID %backend_py_pid%

echo.
echo Chatbot dang chay!
echo Frontend (npm PID: %frontend_npm_pid%)
echo Backend (Python PID: %backend_py_pid%)
echo.
echo Nhan Ctrl+C de thoat tap lenh nay.
echo Cac qua trinh frontend va backend se tiep tuc chay trong nen.
echo Ban se can phai dung chung thu cong.

:loop
timeout /t 1 >nul
goto loop