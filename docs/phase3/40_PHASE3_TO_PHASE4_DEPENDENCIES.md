# 40 — Phase 3 to Phase 4 Dependency Report & Liquidity Handoff

## 1. What Liquidity Functionality Exists in Phase 3
- `SagePair.mint(address to)`: Low-level liquidity share minting with `MINIMUM_LIQUIDITY` locking.
- `SagePair.burn(address to)`: Low-level proportional liquidity burning and asset withdrawal.
- `SageMath.quote()`: Optimal asset ratio computation.
- `SageERC20`: LP token representation with EIP-2612 permit.

---

## 2. What Phase 4 (Liquidity & LP Position System) Will Build
1. **User-Facing Liquidity Router**: Orchestrates `transferFrom` pulls, optimal deposit ratio calculations, and slippage bounds (`amount0Min`, `amount1Min`).
2. **Deadlines & Transaction Execution Protection**: Validates block timestamps to protect against validator transaction withholding.
3. **WETH Native Liquidity Wrapping**: Seamless `addLiquidityETH` and `removeLiquidityETH` flows that wrap/unwrap native ETH into WETH atomically.
4. **Permit-Based LP Management**: Single-transaction `removeLiquidityWithPermit` flows that burn LP shares without prior standalone approvals.

---

## 3. Contracts that Must Remain Immutable
- `SageFactory.sol`: Pair creation logic and pair registry mapping must not be altered.
- `SagePair.sol`: Core $x \cdot y = k$ invariant math, storage layout, and mutex lock are locked and finalized.
