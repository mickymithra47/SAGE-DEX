# 11 — Adding Liquidity: Execution Pipeline & Reserve Updates

## 1. Low-Level Liquidity Addition Flow
In the core AMM, liquidity addition is executed directly at the pool level via `mint(address to)`:

```
USER / ROUTER
 │
 ├── 1. Transfers amount0 of token0 to Pair (token0.transfer(pair, amount0))
 ├── 2. Transfers amount1 of token1 to Pair (token1.transfer(pair, amount1))
 │
 └── 3. Invokes pair.mint(to)
      │
      ├── Measures physical balances (balance0 = token0.balanceOf(pair))
      ├── Computes deposited amounts (amount0 = balance0 - reserve0)
      ├── Calculates liquidity shares to mint
      ├── Mints LP shares to recipient `to`
      ├── Updates reserves (reserve0 = balance0, reserve1 = balance1)
      ├── Updates cumulative price accumulators
      └── Emits Mint(msg.sender, amount0, amount1)
```

---

## 2. Low-Level Separation of Concerns
- The `SagePair` is a low-level execution engine: it does NOT pull funds via `transferFrom`. It simply measures the delta between its physical token balance and stored reserves.
- Future **Routers** (Phase 4) are responsible for pulling tokens from the user via `transferFrom`, calculating optimal ratios, and calling `pair.mint()`.
