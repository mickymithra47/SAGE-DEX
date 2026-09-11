# 29 — Master Protocol & State Invariants

## Core Invariant Specifications

### Factory Invariants:
1. **Uniqueness**: Exactly one pair contract exists per canonical token pair $(t_0, t_1)$.
2. **Order Symmetry**: `getPair(tokenA, tokenB) == getPair(tokenB, tokenA)`.
3. **Immutability**: Once created, a pair's `token0` and `token1` can never be altered.

### Pair Invariants:
1. **Inequality**: `token0 < token1` and `token0 != address(0)`.
2. **Positive Reserves**: $r_0 > 0$ and $r_1 > 0$ after initial mint.
3. **Monotonic Constant Product**: $(1000 \cdot x_1 - 3 \cdot \Delta x_{\text{in}})(1000 \cdot y_1 - 3 \cdot \Delta y_{\text{in}}) \ge 1000^2 \cdot x_0 \cdot y_0$.
4. **Supply Conservation**: $\sum \text{userBalances} + \text{MINIMUM\_LIQUIDITY} \equiv \text{totalSupply}$.
5. **Solvency**: $\text{token0}.\text{balanceOf}(\text{pair}) \ge \text{reserve0}$ and $\text{token1}.\text{balanceOf}(\text{pair}) \ge \text{reserve1}$.
6. **No Liquidity Drain**: Swap outputs must be strictly less than current reserves ($\Delta y < r_y$).
