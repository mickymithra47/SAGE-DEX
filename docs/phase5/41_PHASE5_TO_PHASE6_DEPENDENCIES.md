# 41 — Phase 5 to Phase 6 Dependency Report & Router Handoff

## 1. What Pricing & Oracle Functionality Exists in Phase 5
- `SagePricingLibrary`:
  - `getAmountOut`, `getAmountIn`
  - `getAmountsOut`, `getAmountsIn`
  - `calculatePriceImpactBps`
  - `normalizeDecimals`
  - `computeTWAP`
- `SageQuoter`: Single-hop and multi-hop view-only quote engine with slippage calculations.
- `SageOracleEngine`: TWAP observation registry and sliding lookback engine.

---

## 2. What Phase 6 (Swap Execution & Router Foundation) Will Build
1. **User-Facing Swap Router (`SageRouter`)**:
   - `swapExactTokensForTokens`
   - `swapTokensForExactTokens`
   - `swapExactETHForTokens` / `swapTokensForExactETH`
   - `swapExactTokensForETH` / `swapETHForExactTokens`
2. **Transaction Deadlines & Slippage Enforcement**:
   - Compares expected amounts against `amountOutMin` and `amountInMax`.
   - Reverts on block timestamp expiration (`block.timestamp > deadline`).
3. **Multi-Hop Execution Pipeline**:
   - Orchestrates sequential token transfers and optimistic callbacks across multiple pairs $(A \to B \to C)$.
4. **WETH Native Unwrapping & Safety**:
   - Automated wrapping of `msg.value` and unwrap to recipient address.

---

## 3. Contracts that Must Remain Immutable
- `SageFactory.sol`: Factory registry and CREATE2 logic.
- `SagePair.sol`: Core constant-product pair, mutex, and invariant enforcement.
- `SagePricingLibrary.sol`: Pure mathematical quote and pricing library.
