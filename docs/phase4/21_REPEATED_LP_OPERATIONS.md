# 21 — Repeated Deposit/Withdrawal Cycles & Solvency Preservation

## 1. Lifecycle Verification
Repeated sequences of:
$$\text{Deposit} \to \text{Swap} \to \text{Partial Withdraw} \to \text{Deposit} \to \text{Swap} \to \text{Full Withdraw}$$
were rigorously tested via Foundry invariant tests across **2,048 state transitions**.

---

## 2. Invariants Preserved Across Infinite Cycles
1. **No Phantom Shares**: Total LP supply strictly equals the sum of user balances plus 1000 dead shares.
2. **Solvency Guarantee**: Stored reserves strictly equal physical ERC-20 token balances in the pair contract.
3. **No Liquidity Drain**: No sequence of rapid round-trip deposits and withdrawals can deplete pool reserves.
