@echo off
title URLens - Local Application
color 0A

echo ========================================
echo         URLens Starting...
echo ========================================
echo.

REM Get the directory where this script is located
set "APP_DIR=%~dp0"

REM Start Backend Server (Standalone Executable)
echo [1/2] Starting Local Backend Server...
cd "%APP_DIR%backend"
start /B "" "urlens-backend.exe"

echo Backend server starting on http://localhost:8000
echo.

REM Wait for backend to initialize
echo [2/2] Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

REM Start Frontend Application
echo Starting URLens Application...
cd "%APP_DIR%frontend"
start "" "urlens.exe"

echo.
echo ========================================
echo   URLens is now running!
echo ========================================
echo   Frontend: Windows Application
echo   Backend: http://localhost:8000 (Local)
echo   No internet connection needed!
echo ========================================
echo.
echo Keep this window open to keep the backend running.
echo Close this window to stop the backend server.
echo.
pause

REM Kill backend when script exits
taskkill /F /IM urlens-backend.exe >nul 2>&1
