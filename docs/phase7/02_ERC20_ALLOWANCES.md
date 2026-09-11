# 02 — Standard ERC-20 Allowances & Security Tradeoffs

## 1. Classical ERC-20 Allowance Model
- `approve(spender, amount)`: Writes to `allowance[owner][spender]`.
- `transferFrom(owner, recipient, amount)`: Decrements allowance if not `type(uint256).max`.

---

## 2. Structural Security Limitations
1. **Requires Separate On-Chain Transaction**: First-time traders must submit two transactions: one to approve and one to swap.
2. **Allowance Front-Running Race**: Changing allowance from $N \to M$ allows a malicious spender to front-run the transaction, spend $N$, and then spend $M$.
3. **Spender Exposure**: Long-lived unlimited approvals create catastrophic exposure if a spender contract is ever compromised.
