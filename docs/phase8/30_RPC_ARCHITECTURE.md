# 30 — RPC Architecture & Provider Fallback Strategy

## 1. Provider Tiering
1. **Injected Provider**: Used exclusively for user signing and transaction dispatch.
2. **Public JSON-RPC Client**: Dedicated Viem `publicClient` used for high-frequency reads (quotes, reserves, balances).
3. **Automatic Reconnection**: Backoff retry on transport timeout.
