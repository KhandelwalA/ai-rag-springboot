Here is a more polished, professional, and concise version while preserving all technical details:

---

This project is developed using Spring Boot and Spring AI to demonstrate a Retrieval-Augmented Generation (RAG) workflow leveraging a PostgreSQL-based vector database and the Ollama Mistral LLM.

The solution reads documents placed in the resource folder, splits their content into chunks, converts them into embeddings, and stores those embeddings in the vector database.

A RESTful API is exposed to support user queries. Upon receiving a request, the service retrieves the most relevant embeddings based on the query and provides them to the LLM. The LLM then generates a contextually accurate natural-language response, which is returned as the API output.

