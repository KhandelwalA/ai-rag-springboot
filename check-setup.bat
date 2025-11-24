@echo off
REM Script to check if Docker is properly set up in WSL
REM Run this to verify your setup before starting the application

echo ========================================
echo Docker Setup Verification
echo ========================================
echo.

echo Checking WSL installation...
echo ----------------------------------------
wsl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] WSL is not installed
    echo Please install WSL2 first
    goto :end
) else (
    echo [PASS] WSL is installed
    wsl --version
)

echo.
echo Checking WSL distribution...
echo ----------------------------------------
wsl bash -c "echo [PASS] WSL distribution is accessible"

echo.
echo Checking Docker installation in WSL...
echo ----------------------------------------
wsl bash -c "command -v docker" >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] Docker is not installed in WSL
    echo Please install Docker Engine in WSL
    echo See DOCKER-SETUP.md for instructions
    goto :end
) else (
    echo [PASS] Docker is installed in WSL
    wsl docker --version
)

echo.
echo Checking Docker service status...
echo ----------------------------------------
wsl bash -c "sudo service docker status" | findstr "running" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Docker service is not running
    echo Starting Docker service...
    wsl bash -c "sudo service docker start"
    timeout /t 3 /nobreak >nul
    wsl bash -c "sudo service docker status" | findstr "running" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [FAIL] Failed to start Docker service
        goto :end
    ) else (
        echo [PASS] Docker service started successfully
    )
) else (
    echo [PASS] Docker service is running
)

echo.
echo Checking Docker accessibility...
echo ----------------------------------------
wsl docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] Docker is not accessible without sudo
    echo Please run: wsl bash -c "sudo usermod -aG docker $USER"
    echo Then logout and login to WSL
    goto :end
) else (
    echo [PASS] Docker is accessible
)

echo.
echo Checking Docker Compose...
echo ----------------------------------------
wsl docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] Docker Compose is not installed
    goto :end
) else (
    echo [PASS] Docker Compose is installed
    wsl docker compose version
)

echo.
echo Checking Java installation...
echo ----------------------------------------
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Java is not found in Windows PATH
    echo Make sure Java 17+ is installed
) else (
    echo [PASS] Java is installed
    java -version
)

echo.
echo Checking Maven wrapper...
echo ----------------------------------------
if exist "mvnw.cmd" (
    echo [PASS] Maven wrapper found
) else (
    echo [FAIL] Maven wrapper not found
    goto :end
)

echo.
echo Checking compose.yaml...
echo ----------------------------------------
if exist "compose.yaml" (
    echo [PASS] compose.yaml found
) else (
    echo [FAIL] compose.yaml not found
    goto :end
)

echo.
echo ========================================
echo Setup Verification Complete!
echo ========================================
echo.
echo All checks passed! You can now run the application using:
echo   start-app.bat
echo or
echo   start-app.ps1
echo.

:end
pause

