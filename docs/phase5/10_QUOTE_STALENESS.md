# 10 — Quote Staleness, Mempool Dynamics & Slippage

## 1. Why Quotes Become Stale
- A trade quote is computed against a snapshot of pool reserves at Block $N$.
- In the public mempool, competing transactions or arbitrageur swaps can be included before the user's trade.
- Therefore, the reserve state when the transaction mines may differ from the snapshot:
  $$\text{Reserve}_{\text{execution}} \ne \text{Reserve}_{\text{quote}}$$

---

## 2. Mitigations
1. **Slippage Tolerances (`minAmountOut`)**: Users set an acceptable minimum threshold (e.g. 50 bps / 0.5%).
2. **Transaction Deadlines**: Timeouts prevent transactions from being held in the mempool for extended periods and executed under unfavorable future market conditions.
