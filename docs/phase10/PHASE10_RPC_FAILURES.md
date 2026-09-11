# Phase 10 — RPC Resilience & Adaptive Query Limits

## 1. Fault-Tolerance Controls
- Bounded exponential retries ($t_{\text{wait}} = \min(t_{\text{base}} \cdot 2^k, t_{\text{max}})$).
- Adaptive block range reduction when `eth_getLogs` returns query limit error.
- Circuit breaker tripping on continuous transport exhaustion.
