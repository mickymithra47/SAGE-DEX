# 23 — Transferable LP Positions & Secondary Market Mechanics

## 1. Transferability of LP Shares
Because LP shares are standard ERC-20 tokens (`SageERC20`):
- Users can transfer shares via `transfer(to, amount)` or `transferFrom(from, to, amount)`.
- Transferring LP shares automatically transfers the underlying proportional claim on pool reserves without triggering on-chain liquidity withdrawals or pool reserve updates.

---

## 2. Transfer Lifecycle & Secondary Liquidity
```
Alice (Owns 100 Shares) ──[ transfer(Bob, 40) ]──> Bob (Now Owns 40 Shares)
                                                      │
                                                      └── Bob calls pair.burn(Bob)
                                                            │
                                                            └── Bob receives 40% of pool reserves!
```
- Total supply remains constant.
- Pool solvency remains 100% intact.
