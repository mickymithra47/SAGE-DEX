# 09 — Mint Event Ingestion & Liquidity Addition Tracking

## 1. Event Signature
```solidity
event Mint(address indexed sender, uint256 amount0, uint256 amount1);
```
- Topic: `0x4c209b37986879e7c75c607cd3820285587c08d79acd61535b03725c55920b3f`

---

## 2. Ingestion Details
- Records `amount0` and `amount1` deposited into the pair.
- Paired with LP token `Transfer(address(0), user, lpAmount)` to update position records.
