# Phase 10 — Relational & Time-Series Data Model

## 1. Relational Entities
- `blocks`: `(chainId, blockNumber, blockHash, parentHash, timestamp, isCanonical)`
- `tokens`: `(chainId, address, symbol, name, decimals)`
- `pools`: `(chainId, address, factory, token0, token1, reserve0, reserve1, totalSupply)`
- `swaps`: `(chainId, txHash, logIndex, pool, sender, recipient, amountIn, amountOut, tokenIn, tokenOut)`
- `mints` / `burns`: `(chainId, txHash, logIndex, pool, sender, amount0, amount1)`
- `lp_positions`: `(chainId, pool, user, lpBalance, updatedAtBlock)`
- `candles`: `(chainId, pool, interval, timestamp, open, high, low, close, volume0, volume1)`
