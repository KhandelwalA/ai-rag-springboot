package com.khandelwal.ai.rag.service;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.reader.tika.TikaDocumentReader;
import org.springframework.ai.transformer.splitter.TextSplitter;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;

@Slf4j
@Service
public class DocumentReaderInjestionService {

    @Value("classpath:documents")
    private Resource resource;

    private final VectorStore vectorStore;

    public DocumentReaderInjestionService(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
        log.info("DocumentReaderInjestionService bean created with VectorStore: {}", vectorStore.getClass().getSimpleName());
    }

    @PostConstruct
    public void ingestDocuments() {
        log.info("=".repeat(80));
        log.info("Starting document ingestion process...");
        log.info("=".repeat(80));

        try {
            // Check if resource exists
            if (!resource.exists()) {
                log.error("Resource does not exist: {}", resource);
                return;
            }

            log.info("Resource found: {}", resource.getFilename());
            log.info("Resource content length: {} bytes", resource.contentLength());
            log.info("Resource URI: {}", resource.getURI());

            // Read the documents from the resource
            log.info("Reading document using TikaDocumentReader...");
            TikaDocumentReader tikaDocumentReader = new TikaDocumentReader(resource);
            List<Document> documents = tikaDocumentReader.read();
            log.info("Successfully read {} document(s)", documents.size());

            // Log document content info
            if (!documents.isEmpty()) {
                Document firstDoc = documents.get(0);
                String content = firstDoc.getText();
                log.info("First document content length: {} characters", content != null ? content.length() : 0);
                if (content != null && content.length() > 0) {
                    log.info("First 200 characters: {}", content.substring(0, Math.min(200, content.length())));
                } else {
                    log.warn("Document content is empty or null!");
                }
            }

            // Split the documents into chunks with explicit configuration
            log.info("Splitting documents into chunks...");
            // Configure TokenTextSplitter with explicit parameters
            // defaultChunkSize: 800 tokens, minChunkSizeChars: 350, minChunkLengthToEmbed: 5, maxNumChunks: 10000
            TextSplitter textSplitter = new TokenTextSplitter(800, 350, 5, 10000, true);
            List<Document> chunks = textSplitter.split(documents);
            log.info("Successfully split into {} chunks", chunks.size());

            if (chunks.isEmpty()) {
                log.warn("WARNING: No chunks were created! This means the document content might be empty or the splitter configuration needs adjustment.");
            }

            // Embed and store the chunks in vector store
            log.info("Storing {} chunks in vector store...", chunks.size());
            vectorStore.accept(chunks);
            log.info("Successfully stored all chunks in vector store");

            log.info("=".repeat(80));
            log.info("Document ingestion completed successfully!");
            log.info("=".repeat(80));

        } catch (IOException e) {
            log.error("IOException during document ingestion", e);
            throw new RuntimeException("Failed to ingest documents", e);
        } catch (Exception e) {
            log.error("Unexpected error during document ingestion", e);
            throw new RuntimeException("Failed to ingest documents", e);
        }
    }

    public void queryDocuments(String query) {
        // TODO: Implement query logic
    }

}
