# Quick Start Guide - AI RAG Application with WSL Docker

## 🚀 Quick Start (If Already Set Up)

```cmd
start-app.bat
```

That's it! The script will:
1. Start Docker in WSL
2. Verify everything is working
3. Launch your Spring Boot application
4. Spring Boot will automatically start Ollama and PgVector containers

---

## 📦 First Time Setup

### Step 1: Install Docker in WSL

Open WSL terminal and run this one-liner:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $USER
```

Then **logout and login** to WSL for group changes to take effect.

### Step 2: Enable Docker Auto-start (Optional)

```bash
echo -e "[boot]\nsystemd=true" | sudo tee /etc/wsl.conf
```

Then restart WSL from Windows PowerShell:
```powershell
wsl --shutdown
```

### Step 3: Verify Setup

From Windows Command Prompt in project directory:
```cmd
check-setup.bat
```

This will verify all prerequisites are met.

---

## 🎯 Running the Application

### Method 1: Automated Script (Easiest)

**Windows Command Prompt:**
```cmd
start-app.bat
```

**PowerShell:**
```powershell
.\start-app.ps1
```

### Method 2: Manual

**Step 1 - Start Docker in WSL:**
```bash
wsl sudo service docker start
```

**Step 2 - Run Application from Windows:**
```cmd
mvnw.cmd spring-boot:run
```

### Method 3: Everything from WSL

```bash
# Open WSL terminal
cd /mnt/c/ProjectDocs/AI/ai.rag

# Start Docker
sudo service docker start

# Run application
./mvnw spring-boot:run
```

---

## 🔍 What Happens When You Start

1. **Docker Starts** (in WSL)
   - Docker Engine runs in WSL2 Linux environment

2. **Spring Boot Starts** (on Windows)
   - Detects `compose.yaml` file
   - Automatically runs `docker compose up`

3. **Containers Start** (in WSL Docker)
   - **Ollama** container starts (AI model server)
     - Downloads Mistral model on first run (may take a few minutes)
     - Listens on port 11434
   - **PgVector** container starts (PostgreSQL with vector support)
     - Creates `vectordb` database
     - Listens on port 5432

4. **Application Ready**
   - Spring Boot connects to both services
   - Ready to handle AI RAG requests

---

## 📊 Monitoring

### Check Running Containers

From Windows (if Docker CLI installed) or WSL:
```bash
docker ps
```

You should see:
- `ollama/ollama:latest`
- `pgvector/pgvector:pg16`

### View Container Logs

```bash
# All containers
docker compose logs

# Specific container
docker compose logs ollama
docker compose logs pgvector

# Follow logs
docker compose logs -f
```

### Check Application Logs

The Spring Boot application will show logs in the console where you started it.

---

## 🛑 Stopping the Application

### Stop Application Only

Press `Ctrl+C` in the terminal where the application is running.

Spring Boot will automatically:
- Stop the Docker containers
- Clean up resources

### Stop Containers Manually

```bash
docker compose down
```

### Stop Docker Service in WSL

```bash
wsl sudo service docker stop
```

---

## ⚠️ Troubleshooting

### "Docker is not accessible"

**Problem:** Permission denied when running docker commands

**Solution:**
```bash
# In WSL
sudo usermod -aG docker $USER
# Then logout and login to WSL
exit
# Reopen WSL
```

### "Cannot connect to Docker daemon"

**Problem:** Docker service not running

**Solution:**
```bash
wsl sudo service docker start
```

### "Port already in use"

**Problem:** Ports 11434 or 5432 are already in use

**Solution:**
```cmd
# Check what's using the port
netstat -ano | findstr :11434
netstat -ano | findstr :5432

# Kill the process or change ports in compose.yaml
```

### "Ollama model download is slow"

**Problem:** First run downloads the Mistral model (several GB)

**Solution:** Be patient, this only happens once. You can monitor progress:
```bash
docker compose logs -f ollama
```

### "Spring Boot can't find Docker"

**Problem:** Spring Boot running on Windows can't communicate with Docker in WSL

**Solution:** Make sure Docker is running in WSL:
```bash
wsl docker ps
```

If this works but Spring Boot still fails, try setting DOCKER_HOST:
```cmd
# Windows Command Prompt (as Administrator)
setx DOCKER_HOST "tcp://localhost:2375" /M
```

Then configure Docker in WSL to listen on TCP (see DOCKER-SETUP.md).

---

## 📝 Configuration Files

- **compose.yaml** - Defines Docker containers (Ollama, PgVector)
- **application.properties** - Spring Boot configuration
- **start-app.bat** - Windows batch script to start everything
- **start-app.ps1** - PowerShell script to start everything
- **check-setup.bat** - Verify your setup
- **start-docker.sh** - WSL script to start Docker

---

## 🔗 Useful Commands

```bash
# Check Docker version
docker --version
docker compose version

# List all containers (including stopped)
docker ps -a

# Remove all stopped containers
docker compose down

# View Docker disk usage
docker system df

# Clean up unused resources
docker system prune

# Restart a specific container
docker compose restart ollama
docker compose restart pgvector
```

---

## 📚 More Information

For detailed setup instructions, see **DOCKER-SETUP.md**

For application-specific help, see **HELP.md**

