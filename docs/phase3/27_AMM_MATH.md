# 27 — Pure AMM Math Layer & Integer Precision

## 1. Pure AMM Mathematical Library Specification
`SageMath` provides pure, standalone arithmetic for pricing, swap simulations, and liquidity quotes:

```solidity
library SageMath {
    // 1. Proportional deposit quote
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB);

    // 2. Exact-input swap output with 0.3% fee
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut);

    // 3. Exact-output swap required input with 0.3% fee
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountIn);
}
```

---

## 2. Directional Rounding & Precision Proofs
- `getAmountOut` divides `(997 * aIn * rOut)` by `(1000 * rIn + 997 * aIn)`. Flooring rounds in favor of the liquidity pool.
- `getAmountIn` divides `(rIn * aOut * 1000)` by `(rOut - aOut) * 997` and adds `+1`. Ceiling rounds to guarantee that the deposited tokens are never less than the required invariant threshold.
