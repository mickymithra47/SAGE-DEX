# 38 — Liquidity Events & Off-Chain Indexing Protocols

## 1. Core Liquidity Events

```solidity
// Emitted on liquidity addition
event Mint(address indexed sender, uint256 amount0, uint256 amount1);

// Emitted on liquidity removal
event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

// Emitted on LP token transfer (ERC-20 standard)
event Transfer(address indexed from, address indexed to, uint256 value);
```

---

## 2. Reconstructing Subgraph / Indexer State
An off-chain indexer reconstructs the full protocol state by processing events in chronological block order:
1. `Mint`: Track total volume of assets deposited and newly minted LP shares.
2. `Burn`: Track redeemed asset volume and burned LP shares.
3. `Transfer`: Track user-by-user LP token balances and proportional pool ownership.
