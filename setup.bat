@echo off
echo Setting up TVTS Chatbot environment...

:: Check if Python 3+ is installed
where python3 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python 3+ is required. Please install Python 3 and try again.
    exit /b 1
)

:: Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Node.js is required. Please install Node.js and try again.
    exit /b 1
)

:: Check if Docker is installed
where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Docker is required. Please install Docker and try again.
    exit /b 1
)

:: Install frontend dependencies
echo Installing frontend dependencies...
cd frontend
call npm install
cd ..

:: Install backend dependencies
echo Installing backend dependencies...
cd backend
pip install -r requirements.txt
cd ..

:: Start Qdrant using Docker
echo Starting Qdrant database...
docker run -d -p 6333:6333 qdrant/qdrant:v1.7.4

echo Setup completed successfully!
pause