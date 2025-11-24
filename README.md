This project is built using Spring Boot and Spring AI. It serves as a demonstration of a RAG (Retrieval-Augmented Generation) implementation using Spring AI, a PostgreSQL-based vector database, and the Ollama Mistral LLM.

In this project:

The files placed in the documents folder are read, chunked, and then converted into embeddings.

These embeddings are stored in the vector database.

A RESTful service is exposed for querying the application.

When a query is received, the service retrieves the most relevant chunks from the vector database and passes them to the LLM.

The LLM generates the final response, which is then returned as the API output.
