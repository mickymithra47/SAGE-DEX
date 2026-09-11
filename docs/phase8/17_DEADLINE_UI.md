# 17 — Transaction Deadline UI & Temporal Safety

## 1. Expiration Calculation
$$\text{deadline} = \text{Math.floor}(\text{Date.now}() / 1000) + (\text{deadlineMinutes} \cdot 60)$$

- Default: 5 minutes.
- Guarantees that stalled mempool transactions will revert with `Expired()` rather than execute under changed market conditions.
