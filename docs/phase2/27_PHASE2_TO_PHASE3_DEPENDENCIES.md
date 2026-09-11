# 27 — Phase 2 to Phase 3 Dependencies & AMM Math Bridge

## 1. How Phase 2 Bridges Directly into Phase 3 (AMM Core & Pricing)
Phase 2 establishes the complete token foundation that Phase 3 (AMM Core, Constant Product Invariant, Liquidity Pools, Pricing Engine, and Swap Math) strictly depends on:

```
PHASE 2 (Asset / Token Foundation)
├── SafeTokenTransfer ───────────────► Used by Phase 3 Liquidity Pools to transfer tokens safely
├── TokenAccountingMath ─────────────► Used by Phase 3 Pricing Engine to scale 6/8/18 decimal pairs
├── WETH Canonical Contract ────────► Used by Phase 3 AMM Pairs for Native ETH liquidity pools
├── Balance-Delta Accounting ────────► Used by Phase 3 Swap Engine for fee-on-transfer tokens
├── EIP-2612 Permit & EIP-712 ───────► Used by Phase 3 Routers for single-transaction atomic LP/swaps
└── Category Classification ─────────► Used by Phase 3 Factory to validate token eligibility
```

---

## 2. Direct Code Dependencies for Phase 3
1. `SafeTokenTransfer.safeTransfer` & `SafeTokenTransfer.safeTransferFrom`: The fundamental transfer primitives inside every Phase 3 AMM Pair contract.
2. `TokenAccountingMath.scaleDecimals` & `TokenAccountingMath.mulDivDown` / `mulDivUp`: The core math primitives for computing Constant Product $k = x \cdot y$, swap output amounts, LP share minting, and protocol fee deductions.
3. `WETH.sol`: The canonical wrapped ETH contract paired in primary liquidity pools (e.g. WETH/USDC).
4. `Internal Reserve Tracking`: The state foundation (`reserve0`, `reserve1`) preventing donation attacks on AMM invariant calculations.
