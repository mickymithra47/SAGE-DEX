# 27 — Historical Backfill & Range Batching Engine

## 1. Batch Execution Model
- Splits historical ranges $[S, E]$ into adaptive chunks (e.g. 2,000 blocks).
- Dynamically halves batch size upon encountering RPC `eth_getLogs` limit errors.
- Checkpoints progress after every committed chunk.
