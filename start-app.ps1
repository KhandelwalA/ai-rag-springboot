# PowerShell script to start Docker in WSL and run Spring Boot application
# Run this from PowerShell: .\start-app.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting AI RAG Application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is available
try {
    $wslVersion = wsl --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not found"
    }
    Write-Host "✓ WSL is available" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: WSL is not installed or not available" -ForegroundColor Red
    Write-Host "Please install WSL first" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 1: Starting Docker in WSL..." -ForegroundColor Yellow
Write-Host "----------------------------------------"

# Start Docker service in WSL
wsl bash -c "sudo service docker start" 2>&1 | Out-Null
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Step 2: Verifying Docker is running..." -ForegroundColor Yellow
Write-Host "----------------------------------------"

# Check if Docker is accessible
$dockerCheck = wsl docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ ERROR: Docker is not accessible from WSL" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run the following commands in WSL terminal:" -ForegroundColor Yellow
    Write-Host "  sudo usermod -aG docker `$USER" -ForegroundColor Cyan
    Write-Host "  Then logout and login to WSL" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Docker is running successfully!" -ForegroundColor Green

# Check if Docker is accessible from Windows
Write-Host ""
Write-Host "Step 3: Checking Docker CLI from Windows..." -ForegroundColor Yellow
Write-Host "----------------------------------------"

try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker CLI is available from Windows" -ForegroundColor Green
        Write-Host "  $dockerVersion" -ForegroundColor Gray
    } else {
        Write-Host "⚠ Docker CLI not found in Windows PATH" -ForegroundColor Yellow
        Write-Host "  Spring Boot will try to use WSL Docker" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠ Docker CLI not found in Windows PATH" -ForegroundColor Yellow
    Write-Host "  Spring Boot will try to use WSL Docker" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 4: Starting Spring Boot application..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
Write-Host ""

# Start the Spring Boot application
& .\mvnw.cmd spring-boot:run

Write-Host ""
Read-Host "Press Enter to exit"

