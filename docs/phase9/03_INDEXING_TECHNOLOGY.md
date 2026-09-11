# 03 — Indexing Technology Stack & Infrastructure

## 1. Core Technology Choices
- **Language**: TypeScript / Node.js ES Modules.
- **RPC Ingestion**: Viem JSON-RPC polling & log streaming.
- **Relational Storage**: PostgreSQL 15+ schema with in-memory SQLite / relational repositories.
- **API**: Lightweight REST & GraphQL resolvers with cursor-based pagination.
- **Exclusions**: Zero Go microservices; zero complex multi-tier message queues.
