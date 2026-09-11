# Phase 12 — Indexer Ingestor Deployment & Backfill Runbook

## 1. Indexer Operations
```bash
cd indexer
npm install
npm run build
npm start
```
- Ingests events from `INDEXER_START_BLOCK`.
- Reconciles on-chain reserve states against database records hourly.
- Automatically handles RPC failures via exponential backoff and adaptive query chunking.
