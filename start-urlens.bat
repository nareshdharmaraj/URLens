@echo off
echo Starting URLens Application...
echo.

REM Start Backend Server in new PowerShell window
echo [1/2] Starting Backend Server...
start "URLens Backend" powershell -NoExit -Command "cd '%~dp0backend'; Write-Host 'Activating Python virtual environment...' -ForegroundColor Cyan; .\venv\Scripts\Activate.ps1; Write-Host 'Starting FastAPI server...' -ForegroundColor Green; python main.py"

REM Wait a moment for backend to initialize
timeout /t 3 /nobreak >nul

REM Start Frontend in new PowerShell window
echo [2/2] Starting Flutter Frontend...
start "URLens Frontend" powershell -NoExit -Command "cd '%~dp0frontend'; Write-Host 'Starting Flutter app...' -ForegroundColor Cyan; Write-Host 'Choose your platform when prompted:' -ForegroundColor Yellow; Write-Host '  [1] Windows Desktop' -ForegroundColor White; Write-Host '  [2] Chrome/Edge Browser' -ForegroundColor White; Write-Host '  [3] Android (if device/emulator connected)' -ForegroundColor White; Write-Host '' ; flutter run"

echo.
echo ========================================
echo URLens Application Started!
echo ========================================
echo.
echo Backend:  http://localhost:8000
echo Frontend: Check the Flutter window for platform selection
echo.
echo Press any key to exit this window...
pause >nul
