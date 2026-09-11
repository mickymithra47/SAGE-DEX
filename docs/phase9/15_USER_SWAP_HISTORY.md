# 15 — User Swap History & Execution Auditing

## 1. Trade Ledger Queries
- Query parameters: `userAddress`, `chainId`, `limit` (max 100), `cursor`.
- Returns: `timestamp`, `txHash`, `poolAddress`, `tokenIn`, `tokenOut`, `amountIn`, `amountOut`.
- Enables complete wallet trade history auditing.
