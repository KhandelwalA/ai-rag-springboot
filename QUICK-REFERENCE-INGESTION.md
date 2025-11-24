# Quick Reference - Document Ingestion

## ✅ What Was Fixed

The `ingestDocuments()` method now has:
- ✅ Proper logging with SLF4J
- ✅ Comprehensive error handling
- ✅ Resource validation
- ✅ Detailed progress tracking
- ✅ Better exception handling

---

## 🚀 Quick Test

```bash
# 1. Clean build
mvnw.cmd clean package

# 2. Start Docker
start-app.bat

# 3. Run application
mvnw.cmd spring-boot:run

# 4. Look for these logs:
# "DocumentReaderInjestionService bean created..."
# "Starting document ingestion process..."
# "Document ingestion completed successfully!"
```

---

## 📊 Expected Logs

```
2024-11-17 10:30:15 - DocumentReaderInjestionService bean created with VectorStore: PgVectorStore
2024-11-17 10:30:16 - ================================================================================
2024-11-17 10:30:16 - Starting document ingestion process...
2024-11-17 10:30:16 - ================================================================================
2024-11-17 10:30:16 - Resource found: Fundamentals.pdf
2024-11-17 10:30:16 - Resource content length: 1234567 bytes
2024-11-17 10:30:18 - Successfully read 1 document(s)
2024-11-17 10:30:19 - Successfully split into 45 chunks
2024-11-17 10:30:22 - Successfully stored all chunks in vector store
2024-11-17 10:30:22 - ================================================================================
2024-11-17 10:30:22 - Document ingestion completed successfully!
2024-11-17 10:30:22 - ================================================================================
```

---

## ❌ If No Logs Appear

### Quick Checks:

1. **Docker running?**
   ```bash
   docker ps
   ```

2. **Database accessible?**
   ```bash
   docker exec -it <pgvector-container-id> psql -U testuser -d vectordb
   ```

3. **Ollama ready?**
   ```bash
   curl http://localhost:11434/api/tags
   ```

4. **PDF exists?**
   ```bash
   dir src\main\resources\documents\Fundamentals.pdf
   ```

5. **Run test:**
   ```bash
   mvnw.cmd test -Dtest=DocumentReaderInjestionServiceTest
   ```

---

## 🔍 Common Issues

| Issue | Solution |
|-------|----------|
| No logs at all | Check if application starts successfully |
| "Bean creation exception" | Check Docker containers are running |
| "Resource not found" | Verify PDF file exists |
| "Connection refused" | Check database connection |
| Application hangs | Ollama might be downloading model (wait or increase timeout) |

---

## 📝 Key Files

- **Service:** `src/main/java/com/khandelwal/ai/rag/service/DocumentReaderInjestionService.java`
- **Config:** `src/main/resources/application.properties`
- **Test:** `src/test/java/com/khandelwal/ai/rag/service/DocumentReaderInjestionServiceTest.java`
- **Guide:** `DOCUMENT-INGESTION-TROUBLESHOOTING.md`
- **Summary:** `INGESTION-FIX-SUMMARY.md`

---

## 🆘 Need Help?

1. Read: `DOCUMENT-INGESTION-TROUBLESHOOTING.md`
2. Check: Application startup logs
3. Run: `mvnw.cmd test`
4. Enable: DEBUG logging in `application.properties`

