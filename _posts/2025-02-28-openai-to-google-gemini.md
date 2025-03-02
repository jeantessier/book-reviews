---
layout: post
title: "Switching from OpenAI to Google Gemini"
date: 2025-02-28 12:25:00 -0800
categories: node mongodb ai openai gemini
---
To switch from OpenAI to Google Gemini to create embeddings, I added a
dependency to `@langchain/google-genai`.  Then, I only had to modify the code
that sets up the embeddings computation:

The old code that pointed to OpenAI was:

```JavaScript
const embeddings = new OpenAIEmbeddings({
    model: "text-embedding-3-small",
})
```

The new code that points to Google Gemini is:

```JavaScript
const embeddings = new GoogleGenerativeAIEmbeddings({
    apiKey: process.env.GOOGLE_API_KEY,
    model: "text-embedding-004",
})
```

Because the code relies on a LangChain `Embeddings` interface, I only needed to
change the instance to have everything switch over.

Just a quick note, though.  OpenAI embeddings have 1,536 dimensions but Google
embeddings have only 768 dimentions.  I had to change the vector index in
MongoDB Atlas.

I was able to create embeddings using my Google Gemini API key, and use them
in MongoDB Atlas to actually do vector searches.

It surfaced one more problem.  My `vector_indexer` reads all messages in the
correct order, but all calls to the vector store are asynchronous.  They execute
in an unpredictable order.  As a result, it sometimes processes an entity
deletion **before** the corresponding entity creation.  This leads to entities
that should have been deleted to still exist in the database and be included in
search results.
