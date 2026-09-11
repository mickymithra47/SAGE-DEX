# 08 — Liquidity Minting Pipeline & Reserve Reconciliation

## 1. Low-Level Liquidity Minting Lifecycle

```
USER / CALLER
 │
 ├── 1. Transfers a0 of Token0 to Pair
 ├── 2. Transfers a1 of Token1 to Pair
 │
 └── 3. Calls pair.mint(to)
      │
      ├── [Phase 1: Measure Balance Delta]
      │     balance0 = token0.balanceOf(pair)
      │     balance1 = token1.balanceOf(pair)
      │     amount0 = balance0 - reserve0
      │     amount1 = balance1 - reserve1
      │
      ├── [Phase 2: Calculate Liquidity Shares]
      │     If totalSupply == 0:
      │         liquidity = sqrt(amount0 * amount1) - 1000
      │         _mint(address(0), 1000)
      │     Else:
      │         liquidity = min((amount0 * totalSupply) / reserve0, (amount1 * totalSupply) / reserve1)
      │
      ├── [Phase 3: Mint Shares]
      │     if liquidity == 0 revert InsufficientLiquidityMinted()
      │     _mint(to, liquidity)
      │
      ├── [Phase 4: Update Stored Reserves]
      │     _update(balance0, balance1, reserve0, reserve1)
      └── Emits Mint(msg.sender, amount0, amount1)
```
