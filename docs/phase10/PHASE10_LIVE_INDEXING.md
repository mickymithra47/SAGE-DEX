# Phase 10 — Live Block Indexing & Cursor Tracking

## 1. Live Head Processing
- Polls new canonical blocks from RPC tip.
- Ingests events atomically within transactional boundaries.
- Updates `latestIndexedBlock` cursor pointer.
