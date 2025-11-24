package com.khandelwal.ai.rag.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RagController {

    private static final Logger log = LoggerFactory.getLogger(RagController.class);
    private VectorStore vectorStore;
    private ChatClient ollamaChatClient;

    public RagController(VectorStore vectorStore, @Qualifier("ollamaChatClient") ChatClient ollamaChatClient) {
        this.vectorStore = vectorStore;
        this.ollamaChatClient = ollamaChatClient;
    }

    @PostMapping ("/query")
    public ResponseEntity<String> queryDocuments(@RequestBody String promptMessage) {

        log.info("User asked {} ", promptMessage);
        return ResponseEntity.ok().body(
                    ollamaChatClient.prompt()
                            .advisors(new QuestionAnswerAdvisor(vectorStore))
                            .user(promptMessage)
                            .call()
                            .content());
    }
}
