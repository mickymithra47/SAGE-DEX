# 14 — Reserve Accounting: Stored State vs Physical Balances

## 1. The Dual Balance Model
An Sage AMM Pair maintains two separate representations of asset quantities:

1. **Stored Reserves (`reserve0`, `reserve1`)**:
   - Stored in contract storage Slot 3.
   - Represents the verified accounting balance resulting from legitimate AMM operations (mint, burn, swap).
2. **Physical Token Balances (`token.balanceOf(pair)`)**:
   - The actual token ledger balance recorded in the external ERC-20 token contracts.

---

## 2. Why the Difference Matters
- Physical balances can change outside contract execution (e.g. unsolicited token transfers, direct donations).
- Swap pricing math and liquidity calculations must strictly rely on **Stored Reserves** as the baseline, computing input amounts as:
  $$\text{amount0In} = \text{balance0} - (\text{reserve0} - \text{amount0Out})$$
- This prevents direct token donations from distorting the price curve before an invariant check.
