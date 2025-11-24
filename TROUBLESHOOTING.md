# Troubleshooting Guide - WSL Docker Setup

## Common Issues and Solutions

### 1. Docker Permission Denied

**Symptoms:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Cause:** Your user is not in the docker group

**Solution:**
```bash
# In WSL terminal
sudo usermod -aG docker $USER

# Logout and login to WSL
exit
# Then reopen WSL terminal

# Verify
docker ps
```

---

### 2. Docker Service Not Running

**Symptoms:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Cause:** Docker service is not started

**Solution:**
```bash
# Start Docker service
sudo service docker start

# Check status
sudo service docker status

# If it fails to start, check logs
sudo journalctl -u docker -n 50
```

**Make it auto-start:**
```bash
# Enable systemd in WSL
sudo nano /etc/wsl.conf

# Add:
[boot]
systemd=true

# Save and exit, then restart WSL from PowerShell:
# wsl --shutdown
```

---

### 3. WSL Not Found or Not Working

**Symptoms:**
```
'wsl' is not recognized as an internal or external command
```

**Cause:** WSL is not installed or not in PATH

**Solution:**

**Check if WSL is installed:**
```powershell
# In PowerShell
wsl --version
```

**Install WSL:**
```powershell
# In PowerShell (as Administrator)
wsl --install
# Restart your computer
```

**Install a specific distribution:**
```powershell
wsl --install -d Ubuntu
```

---

### 4. Spring Boot Can't Find Docker

**Symptoms:**
```
Docker Compose is not available
```

**Cause:** Spring Boot on Windows can't communicate with Docker in WSL

**Solutions:**

**Option 1: Install Docker CLI on Windows**
```powershell
# Using winget
winget install Docker.DockerCLI
```

**Option 2: Set DOCKER_HOST environment variable**

In WSL, configure Docker to listen on TCP:
```bash
sudo nano /etc/docker/daemon.json
```

Add:
```json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}
```

Create/edit Docker service override:
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/override.conf
```

Add:
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
```

Restart Docker:
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

In Windows, set environment variable:
```powershell
# PowerShell (as Administrator)
[System.Environment]::SetEnvironmentVariable('DOCKER_HOST', 'tcp://localhost:2375', 'Machine')
```

Restart your terminal/IDE.

---

### 5. Port Already in Use

**Symptoms:**
```
Bind for 0.0.0.0:11434 failed: port is already allocated
```

**Cause:** Another application is using the port

**Solution:**

**Find what's using the port:**
```cmd
# Windows
netstat -ano | findstr :11434
netstat -ano | findstr :5432
```

**Kill the process:**
```cmd
# Windows (replace PID with actual process ID)
taskkill /PID <PID> /F
```

**Or change the port in compose.yaml:**
```yaml
services:
  ollama:
    ports:
      - '11435:11434'  # Changed from 11434
```

Then update `application.properties`:
```properties
spring.ai.ollama.base-url=http://localhost:11435
```

---

### 6. Ollama Model Download Slow or Failing

**Symptoms:**
- Application hangs during startup
- Timeout errors

**Cause:** Ollama is downloading the Mistral model (several GB) on first run

**Solution:**

**Monitor the download:**
```bash
docker compose logs -f ollama
```

**Increase timeout in application.properties:**
```properties
spring.ai.ollama.init.timeout=10m
spring.docker.compose.start.timeout=10m
```

**Pre-download the model:**
```bash
# Start only Ollama container
docker compose up -d ollama

# Pull the model manually
docker exec -it <ollama-container-id> ollama pull mistral

# Check
docker exec -it <ollama-container-id> ollama list
```

---

### 7. Database Connection Failed

**Symptoms:**
```
Connection to localhost:5432 refused
```

**Cause:** PgVector container not running or not ready

**Solution:**

**Check container status:**
```bash
docker compose ps
docker compose logs pgvector
```

**Restart the container:**
```bash
docker compose restart pgvector
```

**Verify database is accessible:**
```bash
docker exec -it <pgvector-container-id> psql -U testuser -d vectordb
```

---

### 8. Maven Build Fails

**Symptoms:**
```
'mvnw.cmd' is not recognized
```

**Cause:** Maven wrapper not found or corrupted

**Solution:**

**Verify files exist:**
```cmd
dir mvnw.cmd
dir .mvn\wrapper
```

**Re-download Maven wrapper:**
```cmd
# If you have Maven installed
mvn wrapper:wrapper

# Or download manually from the project repository
```

---

### 9. Java Version Issues

**Symptoms:**
```
Unsupported class file major version
```

**Cause:** Wrong Java version (needs Java 17+)

**Solution:**

**Check Java version:**
```cmd
java -version
```

**Install Java 17 or higher:**
```powershell
# Using winget
winget install Microsoft.OpenJDK.17

# Or download from https://adoptium.net/
```

**Set JAVA_HOME:**
```powershell
# PowerShell (as Administrator)
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Eclipse Adoptium\jdk-17.0.x', 'Machine')
```

---

### 10. WSL Out of Memory

**Symptoms:**
- Docker containers crash
- WSL becomes unresponsive

**Cause:** WSL using too much memory

**Solution:**

Create `.wslconfig` in your Windows user directory (`C:\Users\<YourUsername>\.wslconfig`):

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

Restart WSL:
```powershell
wsl --shutdown
```

---

### 11. Containers Start But Application Can't Connect

**Symptoms:**
- Containers are running (`docker ps` shows them)
- Application logs show connection errors

**Cause:** Network configuration issue

**Solution:**

**Check if ports are exposed:**
```bash
docker compose ps
```

Should show ports like `0.0.0.0:11434->11434/tcp`

**Test connectivity:**
```cmd
# Windows
curl http://localhost:11434
curl http://localhost:5432
```

**Restart Docker network:**
```bash
docker compose down
docker network prune
docker compose up -d
```

---

### 12. "Compose file not found" Error

**Symptoms:**
```
Compose file 'compose.yaml' not found
```

**Cause:** Spring Boot can't find the compose.yaml file

**Solution:**

**Verify file exists:**
```cmd
dir compose.yaml
```

**Check application.properties:**
```properties
spring.docker.compose.file=./compose.yaml
```

**Use absolute path if needed:**
```properties
spring.docker.compose.file=C:/ProjectDocs/AI/ai.rag/compose.yaml
```

---

## Diagnostic Commands

### Check Everything

```bash
# WSL version
wsl --version

# Docker version
wsl docker --version
wsl docker compose version

# Docker status
wsl sudo service docker status

# Running containers
wsl docker ps

# Container logs
wsl docker compose logs

# Docker disk usage
wsl docker system df

# Network info
wsl docker network ls
```

### Clean Up

```bash
# Stop all containers
docker compose down

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything (careful!)
docker system prune -a
```

---

## Getting Help

If you're still having issues:

1. **Run the setup check:**
   ```cmd
   check-setup.bat
   ```

2. **Collect diagnostic info:**
   ```bash
   wsl docker version > docker-info.txt
   wsl docker compose version >> docker-info.txt
   wsl docker ps -a >> docker-info.txt
   wsl docker compose logs >> docker-info.txt
   ```

3. **Check Spring Boot logs** for specific error messages

4. **Search for the error message** online with context like "Spring Boot Docker Compose WSL"

---

## Useful Resources

- [Docker Engine Installation](https://docs.docker.com/engine/install/ubuntu/)
- [WSL Documentation](https://learn.microsoft.com/en-us/windows/wsl/)
- [Spring Boot Docker Compose Support](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.docker-compose)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [PgVector Documentation](https://github.com/pgvector/pgvector)

