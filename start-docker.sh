
#!/bin/bash
# Script to start Docker in WSL and verify it's running
# Run this from WSL terminal before starting the Spring Boot application

echo "🐳 Starting Docker in WSL..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed in WSL"
    echo "Please install Docker Engine first"
    exit 1
fi

# Start Docker service
if ! sudo service docker status &> /dev/null; then
    echo "Starting Docker service..."
    sudo service docker start
    sleep 3
fi

# Verify Docker is running
if sudo service docker status | grep -q "running"; then
    echo "✅ Docker is running"
else
    echo "❌ Failed to start Docker"
    exit 1
fi

# Test Docker
echo "Testing Docker..."
if docker ps &> /dev/null; then
    echo "✅ Docker is accessible"
else
    echo "⚠️  Docker is running but not accessible without sudo"
    echo "Run: sudo usermod -aG docker $USER"
    echo "Then logout and login again"
fi

# Show Docker version
echo ""
echo "Docker version:"
docker --version
docker compose version

echo ""
echo "✅ Docker is ready!"
echo "You can now start your Spring Boot application from Windows"

