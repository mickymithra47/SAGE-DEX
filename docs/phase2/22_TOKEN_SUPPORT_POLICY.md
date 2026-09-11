# 22 — SAGE DEX Official Token Support & Asset Policy

## 1. Asset Classification Categories

```
┌───────────────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Category                                      │ Policy & Integration Requirements                           │
├───────────────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Category A: Canonical Standard ERC-20         │ 100% Fully Supported across all pools, routers, and vaults. │
│ Category B: Non-Standard Returns (USDT)       │ Supported via SafeTokenTransfer low-level wrapper.          │
│ Category C: Fee-on-Transfer Tokens            │ Supported on Exact-Input swaps with balance delta tracking. │
│ Category D: Rebasing Tokens                   │ Supported ONLY through static share wrappers (e.g. wstETH). │
│ Category E: Blacklist / Pausable Tokens       │ Permitted with explicit UI risk warnings. Isolated pools.   │
│ Category F: Malicious / Reverting Tokens      │ Strictly UNSUPPORTED. Blocked by compatibility engine.      │
└───────────────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```

---

## 2. Explicit Protocol Rules
1. **Rule 1**: The core AMM will never make raw high-level Solidity `transfer` or `transferFrom` calls. All token transfers must execute through `SafeTokenTransfer`.
2. **Rule 2**: Exact-Output swaps are prohibited for Category C (Fee-on-Transfer) tokens.
3. **Rule 3**: Raw rebasing tokens (Category D) cannot be paired directly in constant-product or concentrated liquidity pools.
4. **Rule 4**: Pools are strictly isolated: an issue or blacklist trigger in Token X cannot freeze, drain, or corrupt reserves in unrelated Token Y/Z pools.
