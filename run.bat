@echo off
echo Starting TVTS Chatbot...

:: Start frontend
echo Starting frontend...
cd frontend
start /b cmd /c "npm run dev"
cd ..

:: Start backend
echo Starting backend...
cd backend
start /b cmd /c "uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4"
cd ..

echo Chatbot is running!
echo Press any key to stop the chatbot...
pause >nul

:: Stop all running processes
echo Stopping TVTS Chatbot...
taskkill /IM node.exe /F >nul 2>&1
taskkill /IM python.exe /F >nul 2>&1

echo Chatbot stopped.
pause