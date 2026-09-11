# 22 — Total Value Locked (TVL) & Reserve Accounting

## 1. TVL Definition
$$\text{Pool TVL} = \text{reserve0} + \text{reserve1}$$

- Denominated explicitly in native asset tokens (e.g. $10,000\text{ USDC} + 5.0\text{ WETH}$).
- Derived directly from validated `Sync` and `getReserves()` reads.
