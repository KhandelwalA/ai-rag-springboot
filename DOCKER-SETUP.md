# Docker Setup for WSL (Without Docker Desktop)

This guide explains how to set up and run this Spring Boot AI RAG application using Docker Engine in WSL2 without Docker Desktop.

## Prerequisites

- Windows 10/11 with WSL2 installed
- Ubuntu or Debian distribution in WSL2
- Java 17+ installed on Windows

## Initial Setup (One-time)

### 1. Install Docker Engine in WSL2

Open your WSL terminal and run:

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER
```

**Important:** After adding yourself to the docker group, logout and login to WSL for changes to take effect:
```bash
exit
# Then reopen WSL terminal
```

### 2. Configure Docker Auto-start (Optional but Recommended)

Enable systemd in WSL (requires WSL 0.67.6+):

```bash
sudo nano /etc/wsl.conf
```

Add the following content:
```ini
[boot]
systemd=true
```

Save and exit (Ctrl+X, Y, Enter).

Then restart WSL from Windows PowerShell:
```powershell
wsl --shutdown
```

Reopen WSL terminal. Docker should now start automatically.

### 3. Verify Docker Installation

In WSL terminal:
```bash
# Check Docker version
docker --version
docker compose version

# Test Docker
docker run hello-world

# Verify Docker is running
docker ps
```

## Running the Application

### Option 1: Using the Automated Script (Recommended)

From Windows Command Prompt or PowerShell in the project directory:

**Using Batch Script:**
```cmd
start-app.bat
```

**Using PowerShell Script:**
```powershell
.\start-app.ps1
```

### Option 2: Manual Steps

**Step 1:** Start Docker in WSL
```bash
# In WSL terminal
sudo service docker start
```

**Step 2:** Start the Spring Boot application from Windows
```cmd
# In Windows Command Prompt
mvnw.cmd spring-boot:run
```

### Option 3: Run Everything from WSL

```bash
# In WSL terminal
cd /mnt/c/ProjectDocs/AI/ai.rag

# Start Docker
sudo service docker start

# Run the application
./mvnw spring-boot:run
```

## How It Works

1. **Spring Boot Docker Compose Support**: The application includes `spring-boot-docker-compose` dependency which automatically manages Docker containers.

2. **Automatic Container Management**: When the application starts:
   - Spring Boot detects `compose.yaml` in the project root
   - Executes `docker compose up` to start containers
   - Starts Ollama (AI model server) on port 11434
   - Starts PgVector (PostgreSQL with vector support) on port 5432
   - Waits for services to be ready
   - Connects to these services automatically

3. **WSL Integration**: 
   - Docker Engine runs in WSL2
   - Spring Boot (running on Windows) communicates with Docker in WSL
   - Docker CLI on Windows can access Docker daemon in WSL

## Services Started

The `compose.yaml` defines two services:

- **Ollama**: AI model server (Mistral model)
  - Port: 11434
  - Image: ollama/ollama:latest

- **PgVector**: PostgreSQL with vector extension
  - Port: 5432
  - Database: vectordb
  - User: testuser
  - Password: testpwd

## Troubleshooting

### Docker not accessible without sudo

If you get permission errors:
```bash
# In WSL
sudo usermod -aG docker $USER
# Then logout and login to WSL
```

### Docker service not starting

```bash
# Check Docker status
sudo service docker status

# View Docker logs
sudo journalctl -u docker

# Restart Docker
sudo service docker restart
```

### Spring Boot can't find Docker

Make sure Docker is running in WSL:
```bash
wsl docker ps
```

If this works but Spring Boot still can't find it, you may need to install Docker CLI on Windows or set DOCKER_HOST environment variable.

### Containers not starting

Check Docker logs:
```bash
# In WSL
docker compose logs
docker compose ps
```

### Port conflicts

If ports 11434 or 5432 are already in use:
```bash
# Check what's using the port
netstat -ano | findstr :11434
netstat -ano | findstr :5432
```

## Stopping the Application

When you stop the Spring Boot application (Ctrl+C), it will automatically:
- Stop the Docker containers
- Clean up resources

To manually stop containers:
```bash
# In WSL or Windows (if Docker CLI installed)
docker compose down
```

## Additional Configuration

You can customize Docker Compose behavior in `src/main/resources/application.properties`:

```properties
# Control lifecycle (default: start-and-stop)
spring.docker.compose.lifecycle-management=start-and-stop
# Options: start-and-stop, start-only, none

# Wait timeout
spring.docker.compose.start.timeout=5m

# Skip Docker Compose entirely
spring.docker.compose.enabled=false
```

## Resources

- [Docker Engine Installation](https://docs.docker.com/engine/install/ubuntu/)
- [Spring Boot Docker Compose Support](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.docker-compose)
- [WSL Documentation](https://learn.microsoft.com/en-us/windows/wsl/)

