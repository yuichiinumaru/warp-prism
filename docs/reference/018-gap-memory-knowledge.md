# Feature Catalog: Gap — Memory & Knowledge System

> **Series**: 1800
> **EPICs**: EPIC-1800 (Memory System), EPIC-1810 (Memory Storage & Retrieval), EPIC-1820 (Knowledge Integration)
> **Gap Source**: diegosouza-omniroute (memory extraction, injection, retrieval, summarization, store with vector search)
> **Total Features**: 30

## Gap Analysis Summary

Our catalog has no features related to a persistent memory system. The diegosouza reference implements a full memory system with:
- **Memory extraction** — automatically extract notable facts, preferences, and context from conversations
- **Memory injection** — inject relevant memories into new conversations as context
- **Memory retrieval** — vector-similarity-based memory search
- **Memory summarization** — summarize and deduplicate memories over time
- **Memory store** — persistent storage with vector search capability

This is a significant gap for any system aspiring to support agentic workflows where context persists across sessions.

## Classification Guide

- **EXTENDED**: Core memory system — valuable for agentic use cases but not required for basic gateway
- **ECOSYSTEM**: Advanced memory features (auto-summarization, knowledge graphs)

---

## Features

### Memory System Core (1800-1809)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1800 | Memory Domain Model | Define `Memory` entity: ID, subject (user/session), key, content, embedding vector, source (conversation ID), tags, relevance score, created, updated, expires | EXTENDED | P2 | EPIC-1800 (new) |
| 1801 | Memory Repository | Implement `MemoryRepository` — Create, GetByID, Search (vector similarity), List by subject, Update, Delete with PostgreSQL + pgvector extension | EXTENDED | P2 | EPIC-1800 |
| 1802 | Memory Extraction | Implement memory extraction: analyze conversation turns, identify notable facts/preferences/instructions, create memory entries automatically | EXTENDED | P2 | EPIC-1800 |
| 1803 | Memory Extraction Rules | Configurable extraction rules: what to extract (facts, preferences, names, goals), minimum confidence threshold, excluded topics | EXTENDED | P2 | EPIC-1800 |
| 1804 | Memory Injection | Implement memory injection: before forwarding request to LLM, retrieve relevant memories and inject as additional context (system message or prefixed messages) | EXTENDED | P2 | EPIC-1800 |
| 1805 | Memory Injection Configuration | Configure memory injection per exposure: enable/disable, max memories to inject, injection location (system prompt, before user message), max tokens for memories | EXTENDED | P2 | EPIC-1800 |
| 1806 | Memory Scoping | Scope memories to subjects: per-user memories, per-session memories, per-API-key memories, shared organization memories | EXTENDED | P2 | EPIC-1800 |
| 1807 | Memory API Endpoints | Admin and user-facing memory endpoints: list memories, search, create manual memory, delete, update; per-subject access control | EXTENDED | P2 | EPIC-1800 |
| 1808 | Memory Lifecycle | Implement memory lifecycle: creation, relevance decay over time, manual pin (never decay), expiry, soft delete, retention policy | EXTENDED | P2 | EPIC-1800 |
| 1809 | Memory Metrics | Track memory system metrics: memories created/retrieved per conversation, injection hit rate, storage size per subject | EXTENDED | P2 | EPIC-1800 |

### Memory Storage & Retrieval (1810-1819)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1810 | Vector Embedding Generation | Generate embedding vectors for memories: use embedding model (OpenAI, local) to create vectors for semantic search | EXTENDED | P2 | EPIC-1810 (new) |
| 1811 | pgvector Integration | Integrate pgvector extension for PostgreSQL: store embedding vectors, create HNSW/IVFFlat indexes for similarity search | EXTENDED | P2 | EPIC-1810 |
| 1812 | Semantic Memory Search | Implement semantic memory search: embed query, find nearest memories by cosine similarity, filter by subject/tags/recency | EXTENDED | P2 | EPIC-1810 |
| 1813 | Memory Deduplication | Deduplicate memories: detect semantically similar memories for same subject, merge or keep most recent, prevent memory bloat | EXTENDED | P2 | EPIC-1810 |
| 1814 | Memory Summarization | Summarize related memories: periodically consolidate many small memories into fewer comprehensive summaries using LLM | ECOSYSTEM | P3 | EPIC-1810 |
| 1815 | Memory Importance Scoring | Score memory importance: frequency of retrieval, recency, explicit user marking, relevance to recent conversations | EXTENDED | P2 | EPIC-1810 |
| 1816 | Memory Capacity Limits | Enforce per-subject memory limits: max memories, max total tokens, oldest/lowest-importance eviction when limit reached | EXTENDED | P2 | EPIC-1810 |
| 1817 | Memory Export/Import | Export/import memories per subject: JSON format for backup, migration, or user data portability (GDPR) | EXTENDED | P3 | EPIC-1810 |
| 1818 | Memory Search Caching | Cache recent memory search results: short TTL, invalidate on new memory creation, reduce embedding API calls | EXTENDED | P2 | EPIC-1810 |
| 1819 | Memory Storage Tests | Test suite for memory storage: vector search accuracy, deduplication, capacity limits, lifecycle management | EXTENDED | P2 | EPIC-1810 |

### Knowledge Integration (1820-1829)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1820 | Knowledge Base Interface | Define `KnowledgeBase` interface: `Search(ctx, query, options)`, `Ingest(ctx, document)`, `Delete(ctx, docID)` — unified interface for RAG sources | ECOSYSTEM | P3 | EPIC-1820 (new) |
| 1821 | Document Ingestion | Implement document ingestion: split documents into chunks, generate embeddings, store in vector database | ECOSYSTEM | P3 | EPIC-1820 |
| 1822 | RAG Pipeline | Implement basic RAG pipeline: on request, search knowledge base, inject relevant chunks as context, send to LLM | ECOSYSTEM | P3 | EPIC-1820 |
| 1823 | RAG Configuration | Configure RAG per exposure: enable/disable, knowledge base sources, max chunks, chunk size, relevance threshold | ECOSYSTEM | P3 | EPIC-1820 |
| 1824 | Document Format Support | Support document formats for ingestion: plain text, Markdown, PDF (via extraction), HTML (via parsing) | ECOSYSTEM | P3 | EPIC-1820 |
| 1825 | Knowledge Base Admin | Admin endpoints for knowledge base management: list documents, ingest, delete, search, view chunks, re-embed | ECOSYSTEM | P3 | EPIC-1820 |
| 1826 | Citation Tracking | Track citations in RAG responses: which chunks contributed to response, source document attribution | ECOSYSTEM | P3 | EPIC-1820 |
| 1827 | Knowledge Base Capacity | Enforce knowledge base capacity: max documents, max chunks, max storage size per organization/subject | ECOSYSTEM | P3 | EPIC-1820 |
| 1828 | Knowledge Base Sync | Support periodic sync from external sources: S3 bucket, Git repository, API endpoint, webhooks for updates | ECOSYSTEM | P3 | EPIC-1820 |
| 1829 | Knowledge Base Tests | Test suite for knowledge base: ingestion, chunking, embedding, search accuracy, RAG pipeline | ECOSYSTEM | P3 | EPIC-1820 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1800 (Memory Model) | 120 (Capability Type) | Memories are a new domain entity, not a capability |
| 1804 (Memory Injection) | 1610-1618 (Compression) | Memory injection adds tokens; compression removes them; coordinate |
| 1810 (Embedding Gen) | 775 (Embeddings Endpoint) | Reuses embedding infrastructure for memory vectors |
| 1811 (pgvector) | 170-175 (PostgreSQL) | Extends PostgreSQL with vector search extension |
| 1812 (Semantic Search) | 877 (Embedding Similarity Cache) | Similar technology; cache uses embeddings for response similarity |
| 1822 (RAG) | 1030-1033 (Parallel Search) | RAG is knowledge search; 1030 is web search; similar patterns |
