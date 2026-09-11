# SAGE Database & Indexing Documentation

This directory details database schema definitions, block ingestion pipelines, and state storage.

## Components
- **Database Schema**: SQL migrations and table layouts in [`indexer/src/db/schema.sql`](../../indexer/src/db/schema.sql).
- **Storage Layer**: Type-safe DB adapter in [`indexer/src/db/database.ts`](../../indexer/src/db/database.ts).
- **Specifications**: See [`docs/phase9/`](../phase9/) and [`docs/phase10/`](../phase10/) for indexer models, reorg handlers, and reconciliation jobs.
