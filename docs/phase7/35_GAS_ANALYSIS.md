# 35 — Quantitative Gas Benchmarks & Comparison

## Phase 7 Quantitative Gas Profile

```
┌──────────────────────────────────────────────┬──────────────────┬──────────────────┐
│ Flow                                         │ Total Gas (Est.) │ Transactions     │
├──────────────────────────────────────────────┼──────────────────┼──────────────────┤
│ 1. Standard ERC-20 Approve + Swap            │ ~133,000 gas     │ 2 transactions   │
│ 2. EIP-2612 Permit + Swap (Atomic)           │ ~149,700 gas     │ 1 transaction    │
│ 3. Permit2 Signature Transfer + Swap (Atomic)│ ~152,700 gas     │ 1 transaction    │
│ 4. Permit2 Standalone Signature Transfer     │ ~85,800 gas      │ 1 transaction    │
└──────────────────────────────────────────────┴──────────────────┴──────────────────┘
```

- **Key Takeaway**: While signature authorization uses slightly more gas in a single execution due to ecrecover, it collapses 2 transactions into 1, dramatically improving user experience.
