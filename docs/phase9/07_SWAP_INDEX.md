# 07 — Swap Event Ingestion & Accounting

## 1. Event Signature
```solidity
event Swap(
    address indexed sender,
    address indexed recipient,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out
);
```
- Topic: `0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822`

---

## 2. Ingestion Keys
- Primary identity: `(chainId, txHash, logIndex)` guaranteeing strict idempotency.
