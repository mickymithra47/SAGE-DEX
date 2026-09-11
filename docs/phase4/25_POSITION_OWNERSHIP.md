# 25 — Fungible LP Ownership vs Concentrated Non-Fungible Positions

## 1. Full-Range Fungible Ownership (Phase 4)
In Sage Phase 4:
- All liquidity deposited into an `SagePair` is distributed across the entire price interval from $0$ to $\infty$.
- Every unit of LP share in a pool is identical, interchangeable, and fungible.
- Ownership is tracked via simple ERC-20 token balances (`pair.balanceOf(user)`).

---

## 2. Why No NFT Positions in Phase 4?
- NFT positions (e.g. Uniswap V3 style) are required ONLY when liquidity is concentrated within discrete price bounds $[P_{\text{lower}}, P_{\text{upper}}]$.
- In full-range constant product AMMs, using ERC-20 tokens eliminates the massive gas overhead and indexing complexity of non-fungible token IDs.
