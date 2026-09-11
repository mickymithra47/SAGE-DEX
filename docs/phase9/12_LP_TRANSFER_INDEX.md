# 12 — LP Token Transfer Indexing & Ownership Movement

## 1. ERC-20 Transfer Signature
```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```
- Topic: `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`

---

## 2. Transfer Semantics
- `from == 0x0`: LP Mint (liquidity added).
- `to == 0x0`: LP Burn (liquidity removed).
- `from != 0x0 && to != 0x0`: Secondary LP token transfer between users.
- Reconstructs accurate LP position ledgers in real time.
