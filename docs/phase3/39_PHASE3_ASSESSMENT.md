# 39 — Phase 3 Protocol Engineering Assessment & Technical Review

## 1. Architectural Takeaways
1. **The Pool is the Sovereign Financial Authority**: The pair contract manages reserves and invariant enforcement autonomously, without depending on external routers or frontends.
2. **Balance Deltas Neutralize Fee-on-Transfer Discrepancies**: Directly measuring `balanceOf(this)` post-transfer guarantees that the pool only credits tokens it physically holds.
3. **Minimum Liquidity Burn is Essential**: Locking 1,000 wei of LP shares to `address(0)` on initial pool mint mathematically eliminates first-depositor share inflation attacks.
4. **Optimistic Transfers Unify Swaps and Flash Loans**: Transferring output tokens before verifying invariant satisfaction provides zero-cost flash loans while preserving total solvency.
