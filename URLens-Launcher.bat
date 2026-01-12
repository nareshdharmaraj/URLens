@echo off
title URLens Application Launcher
color 0A

echo ========================================
echo         URLens Starting...
echo ========================================
echo.

REM Get the directory where this script is located
set "APP_DIR=%~dp0"

REM Start Backend Server
echo [1/2] Starting Backend Server...
cd "%APP_DIR%backend"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    call venv\Scripts\activate.bat
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    call venv\Scripts\activate.bat
)

REM Start backend in background
start /B python -m uvicorn app.main:app --host 127.0.0.1 --port 8000

echo Backend server started on http://localhost:8000
echo.

REM Wait for backend to be ready
echo [2/2] Waiting for backend to be ready...
timeout /t 3 /nobreak >nul

REM Start Frontend Application
echo Starting URLens Application...
cd "%APP_DIR%frontend\build\windows\x64\runner\Release"
start "" urlens.exe

echo.
echo ========================================
echo   URLens is now running!
echo ========================================
echo   Frontend: Windows Application
echo   Backend: http://localhost:8000
echo ========================================
echo.
echo Keep this window open to keep the backend running.
echo Close this window to stop the backend server.
echo.
pause
