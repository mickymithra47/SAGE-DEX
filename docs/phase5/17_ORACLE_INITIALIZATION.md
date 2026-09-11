# 17 — Oracle Initialization & Empty Pool Handling

## 1. Zero Reserve Protection
- If `reserve0 == 0` or `reserve1 == 0`, cumulative price accumulation is **skipped**.
- This prevents division-by-zero panics and avoids logging meaningless infinite or zero prices prior to initial liquidity provisioning.

---

## 2. First Deposit Initialization
- When initial liquidity is deposited, `blockTimestampLast` is initialized to the current block timestamp, with cumulative prices initialized to `0`.
- The first time-weighted interval begins accumulating on the subsequent block transition.
