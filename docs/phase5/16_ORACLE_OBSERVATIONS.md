# 16 — Historical Observations & Sliding Window Architecture

## 1. Observation Data Structure
In `SageOracleEngine`:
```solidity
struct Observation {
    uint32 timestamp;
    uint256 price0Cumulative;
    uint256 price1Cumulative;
}
```

---

## 2. Sliding Window Query Architecture
- `SageOracleEngine` records chronological observations indexed by timestamp.
- When `consult(pair, tokenIn, amountIn, lookbackSeconds)` is invoked:
  1. The oracle identifies the historical observation recorded at $T_{\text{target}} \le \text{currentTimestamp} - \text{lookbackSeconds}$.
  2. The oracle reads the current cumulative price (including pending time elapsed in the current block).
  3. TWAP is calculated across the exact elapsed window:
     $$\Delta \text{Cumulative} = \text{cumulative}_{\text{current}} - \text{cumulative}_{\text{past}}$$
     $$\Delta t = \text{timestamp}_{\text{current}} - \text{timestamp}_{\text{past}}$$
