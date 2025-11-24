@echo off
REM Script to start Docker in WSL and then run the Spring Boot application
REM Run this from Windows Command Prompt or PowerShell

echo ========================================
echo Starting AI RAG Application
echo ========================================
echo.

REM Check if WSL is available
wsl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: WSL is not installed or not available
    echo Please install WSL first
    pause
    exit /b 1
)

echo Step 1: Starting Docker in WSL...
echo ----------------------------------------
wsl bash -c "sudo service docker start"
timeout /t 3 /nobreak >nul

echo.
echo Step 2: Verifying Docker is running...
echo ----------------------------------------
wsl docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not accessible from WSL
    echo Please run the following commands in WSL:
    echo   sudo usermod -aG docker $USER
    echo   Then logout and login to WSL
    pause
    exit /b 1
)

echo Docker is running successfully!
echo.

echo Step 3: Starting Spring Boot application...
echo ----------------------------------------
echo.

REM Start the Spring Boot application
call mvnw.cmd spring-boot:run

pause

