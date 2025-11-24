# Document Ingestion Troubleshooting Guide

## Issue: `ingestDocuments()` Method Not Executing

This guide helps diagnose why the `@PostConstruct` method in `DocumentReaderInjestionService` might not be executing at runtime.

---

## ✅ What Has Been Fixed

The service has been updated with:

1. **Better Logging** - Using SLF4J with Lombok's `@Slf4j` instead of `System.out.println`
2. **Error Handling** - Comprehensive try-catch blocks with detailed error messages
3. **Validation** - Checks if resource exists before processing
4. **Detailed Progress Tracking** - Logs each step of the ingestion process
5. **Logging Configuration** - Added DEBUG level logging for your package

---

## 🔍 Common Reasons Why @PostConstruct Might Not Execute

### 1. Application Fails to Start

**Symptom:** Application crashes or stops during startup

**Check:**
```bash
# Look for errors in the startup logs
# Common errors:
# - "Failed to configure a DataSource"
# - "Could not connect to database"
# - "Bean creation exception"
```

**Solution:**
- Ensure Docker containers (Ollama, PgVector) are running
- Check database connection settings
- Verify all required dependencies are available

---

### 2. VectorStore Bean Not Available

**Symptom:** Error like "No qualifying bean of type 'VectorStore'"

**Cause:** The `VectorStore` bean cannot be created, so `DocumentReaderInjestionService` cannot be created either

**Check:**
```bash
# Look for errors related to:
# - PgVector connection
# - Database initialization
# - Spring AI autoconfiguration
```

**Solution:**

**Verify PgVector is running:**
```bash
docker ps | grep pgvector
```

**Test database connection:**
```bash
# From WSL or Windows (if psql installed)
psql -h localhost -p 5432 -U testuser -d vectordb
# Password: testpwd
```

**Check application.properties:**
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/vectordb
spring.datasource.username=testuser
spring.datasource.password=testpwd
spring.ai.vectorstore.pgvector.initialize-schema=true
```

---

### 3. Exception During Initialization

**Symptom:** Method starts but fails silently

**Previous Issue:** The old code threw `IOException` which might have been caught by Spring

**Solution:** The updated code now:
- Catches all exceptions
- Logs detailed error messages
- Re-throws as `RuntimeException` to make failures visible

---

### 4. Resource File Not Found

**Symptom:** Error "Resource does not exist"

**Check:**
```bash
# Verify the PDF file exists
dir src\main\resources\documents\Fundamentals.pdf

# Or in WSL
ls -la src/main/resources/documents/Fundamentals.pdf
```

**Solution:**
- Ensure the PDF file is in the correct location
- Check file permissions
- Verify the file is included in the build (not in .gitignore)

---

### 5. Ollama Not Ready

**Symptom:** Application hangs or times out during startup

**Cause:** Ollama is downloading the Mistral model (several GB) on first run

**Check:**
```bash
# Monitor Ollama logs
docker logs -f <ollama-container-id>

# Or using compose
docker compose logs -f ollama
```

**Solution:**

**Increase timeout:**
```properties
spring.ai.ollama.init.timeout=10m
```

**Pre-download the model:**
```bash
# Start Ollama container
docker compose up -d ollama

# Pull the model manually
docker exec -it <ollama-container-id> ollama pull mistral

# Verify
docker exec -it <ollama-container-id> ollama list
```

---

## 🔧 How to Verify the Fix

### Step 1: Clean and Rebuild

```bash
# Windows
mvnw.cmd clean package

# Or WSL
./mvnw clean package
```

### Step 2: Start Docker Containers

```bash
# Using the helper script
start-app.bat

# Or manually
wsl sudo service docker start
```

### Step 3: Run the Application

```bash
mvnw.cmd spring-boot:run
```

### Step 4: Check the Logs

You should now see detailed logs like:

```
2024-11-17 10:30:15 - DocumentReaderInjestionService bean created with VectorStore: PgVectorStore
2024-11-17 10:30:16 - ================================================================================
2024-11-17 10:30:16 - Starting document ingestion process...
2024-11-17 10:30:16 - ================================================================================
2024-11-17 10:30:16 - Resource found: Fundamentals.pdf
2024-11-17 10:30:16 - Resource content length: 1234567 bytes
2024-11-17 10:30:16 - Resource URI: file:/C:/ProjectDocs/AI/ai.rag/target/classes/documents/Fundamentals.pdf
2024-11-17 10:30:16 - Reading document using TikaDocumentReader...
2024-11-17 10:30:18 - Successfully read 1 document(s)
2024-11-17 10:30:18 - Splitting documents into chunks...
2024-11-17 10:30:19 - Successfully split into 45 chunks
2024-11-17 10:30:19 - Storing 45 chunks in vector store...
2024-11-17 10:30:22 - Successfully stored all chunks in vector store
2024-11-17 10:30:22 - ================================================================================
2024-11-17 10:30:22 - Document ingestion completed successfully!
2024-11-17 10:30:22 - ================================================================================
```

---

## 🚨 If You Still Don't See Logs

### Check 1: Verify Service is Being Created

Add this to your `Application.java`:

```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(Application.class, args);
        
        // Check if the bean exists
        if (context.containsBean("documentReaderInjestionService")) {
            System.out.println("✓ DocumentReaderInjestionService bean is registered");
        } else {
            System.out.println("✗ DocumentReaderInjestionService bean is NOT registered");
        }
    }
}
```

### Check 2: Verify Component Scanning

Ensure your service package is being scanned. The `@SpringBootApplication` annotation on `Application.java` should scan all packages under `com.khandelwal.ai.rag`.

### Check 3: Check for Conditional Annotations

Make sure there are no `@Conditional` annotations preventing bean creation.

### Check 4: Enable Debug Logging

Add to `application.properties`:

```properties
logging.level.org.springframework.context=DEBUG
logging.level.org.springframework.beans=DEBUG
```

This will show all bean creation activity.

---

## 🔍 Diagnostic Commands

### Check Application Startup

```bash
# Run with debug output
mvnw.cmd spring-boot:run -Ddebug=true
```

### Check Database Connection

```bash
# Test PostgreSQL connection
docker exec -it <pgvector-container-id> psql -U testuser -d vectordb -c "\dt"
```

### Check Ollama Status

```bash
# Check if Ollama is responding
curl http://localhost:11434/api/tags

# Or from Windows
Invoke-WebRequest -Uri http://localhost:11434/api/tags
```

### Check Vector Store

```bash
# Connect to database and check vector_store table
docker exec -it <pgvector-container-id> psql -U testuser -d vectordb

# In psql:
\dt
SELECT COUNT(*) FROM vector_store;
```

---

## 📝 Expected Behavior

When everything works correctly:

1. **Application starts** - Spring Boot initializes
2. **Docker containers start** - Ollama and PgVector (if using docker-compose support)
3. **VectorStore bean created** - PgVectorStore is initialized
4. **DocumentReaderInjestionService created** - Constructor is called
5. **@PostConstruct executed** - `ingestDocuments()` method runs
6. **PDF is read** - TikaDocumentReader processes the PDF
7. **Text is split** - TokenTextSplitter creates chunks
8. **Embeddings created** - Ollama generates embeddings
9. **Vectors stored** - PgVector stores the embeddings
10. **Application ready** - Ready to handle requests

---

## 🆘 Still Having Issues?

### Collect Diagnostic Information

```bash
# 1. Check Java version
java -version

# 2. Check Docker status
docker ps

# 3. Check application logs
# Save the full startup log to a file

# 4. Check database
docker exec -it <pgvector-container-id> psql -U testuser -d vectordb -c "\dt"

# 5. Check Ollama
curl http://localhost:11434/api/tags
```

### Common Error Messages and Solutions

**"Failed to configure a DataSource"**
- Solution: Ensure PgVector container is running and accessible

**"Connection refused"**
- Solution: Check if services are running on correct ports

**"Bean creation exception"**
- Solution: Check application logs for the root cause

**"Resource not found"**
- Solution: Verify PDF file exists in src/main/resources/documents/

**"Timeout waiting for Ollama"**
- Solution: Increase timeout or pre-download the model

---

## 📚 Additional Resources

- [Spring @PostConstruct Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/PostConstruct.html)
- [Spring AI Documentation](https://docs.spring.io/spring-ai/reference/)
- [PgVector Documentation](https://github.com/pgvector/pgvector)
- [Ollama Documentation](https://github.com/ollama/ollama)

