# Phase 10 — Ingestion Engine & Processing Pipeline

## 1. Engine Flow
1. Fetch latest blocks and contract event logs via Viem RPC.
2. Decode raw event logs through typed ABI decoders.
3. Validate sequential block continuity and `parentHash` matching.
4. Execute atomic database transaction.
5. Advance cursor checkpoint.
