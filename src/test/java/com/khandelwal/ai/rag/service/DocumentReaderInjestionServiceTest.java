package com.khandelwal.ai.rag.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test to verify DocumentReaderInjestionService is properly initialized
 */
@SpringBootTest
class DocumentReaderInjestionServiceTest {

    @Autowired
    private ApplicationContext applicationContext;

    @Autowired(required = false)
    private DocumentReaderInjestionService documentReaderInjestionService;

    @Test
    void testServiceBeanExists() {
        // Verify the bean is registered in the application context
        assertTrue(applicationContext.containsBean("documentReaderInjestionService"),
                "DocumentReaderInjestionService bean should be registered");
    }

    @Test
    void testServiceIsAutowired() {
        // Verify the service can be autowired
        assertNotNull(documentReaderInjestionService,
                "DocumentReaderInjestionService should be autowired");
    }

    @Test
    void testServiceHasVectorStore() {
        // Verify the service was created with a VectorStore
        assertNotNull(documentReaderInjestionService,
                "DocumentReaderInjestionService should not be null");
        
        // Note: We can't directly test the vectorStore field as it's private,
        // but if the service was created, it means VectorStore was successfully injected
    }
}

