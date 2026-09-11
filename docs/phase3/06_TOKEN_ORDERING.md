# 06 — Deterministic Token Ordering & Duplicate Pool Prevention

## 1. Why Deterministic Token Ordering is Mandatory
In an AMM, a market between Token A and Token B is economically symmetric to a market between Token B and Token A:
- If a DEX allowed separate pools for `(TokenA, TokenB)` and `(TokenB, TokenA)`, liquidity would be fragmented across two disjoint contracts.
- Fragmented liquidity doubles price slippage for traders and reduces fee yield for liquidity providers.

---

## 2. Canonical Token Ordering Rule
When creating a pair, the factory sorts the two token addresses strictly in ascending numerical order:

```solidity
(address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
```

### Protocol Invariants:
1. `token0 < token1`: Guaranteed by strict address inequality.
2. `token0 != address(0)`: Eliminates zero-address parameters.
3. `getPair[tokenA][tokenB] == getPair[tokenB][tokenA]`: Bidirectional lookup points to the identical unique pair contract.
