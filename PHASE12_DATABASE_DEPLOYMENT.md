# Phase 12 — PostgreSQL Database Deployment & Migrations

## 1. Database Provisioning
- **Engine**: PostgreSQL 15+
- **Schema Initialization**: `indexer/src/db/schema.sql`
- **Data Safety**:
  - Tables use `NUMERIC` types for large token balances without precision loss.
  - Foreign keys ensure referential integrity between pools and tokens.
  - Reorg rollbacks execute via atomic SQL transactions.
