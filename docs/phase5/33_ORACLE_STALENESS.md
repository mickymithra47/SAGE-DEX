# 33 — Oracle Staleness, Inactive Pools & Freshness Bounds

## 1. Defining Staleness
- An observation is **Stale** if no update has occurred within the user's required lookback period:
  $$t_{\text{current}} - t_{\text{lastObservation}} > \text{maxAllowedStaleness}$$

---

## 2. Revert Guarantees
In `SageOracleEngine`:
- If no observations exist for a pair: Reverts with `Uninitialized()`.
- If observations exist but elapsed time is zero: Reverts with `InsufficientHistory()`.
- If requested lookback is zero: Reverts with `InvalidLookback()`.
- The oracle never returns silent default values or zero prices on invalid queries.
