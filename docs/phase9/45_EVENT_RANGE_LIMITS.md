# 45 — Adaptive Event Range Limiting & Log Pagination

## 1. Dynamic Block Range Optimization
- Initial chunk: 2,000 blocks.
- On RPC error `query returned more than 10000 results`:
  $$\text{Chunk Size} \leftarrow \left\lfloor \frac{\text{Chunk Size}}{2} \right\rfloor$$
- Upon successful contiguous processing, chunk size gradually expands back to target capacity.
