# 10 — Burn Event Ingestion & Liquidity Removal Tracking

## 1. Event Signature
```solidity
event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
```
- Topic: `0xdccd412f0b1252819cb1fd330b93224ca42612892bb3f4f789976e6d81936496`

---

## 2. Ingestion Details
- Records withdrawn underlying tokens (`amount0`, `amount1`) returned to `to`.
- Updates LP total supply and recipient balance records.
