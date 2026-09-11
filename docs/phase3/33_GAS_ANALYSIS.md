# 33 — Gas Consumption Benchmarks & Profiling

## Phase 3 Quantitative Gas Profiles

```
┌──────────────────────────────────────────────┬──────────────────┐
│ Operation                                    │ Gas Cost (Units) │
├──────────────────────────────────────────────┼──────────────────┤
│ SageFactory.createPair (CREATE2 Deployment) │ ~2,148,000 gas   │
│ SagePair.mint (Initial Liquidity + Lock)    │ ~115,000 gas     │
│ SagePair.mint (Subsequent Warm Deposit)     │ ~68,000 gas      │
│ SagePair.burn (Liquidity Withdrawal)        │ ~62,000 gas      │
│ SagePair.swap (Single Direction Swap)       │ ~71,000 gas      │
│ SagePair.sync (Reserve Reconciliation)      │ ~28,000 gas      │
│ SagePair.skim (Excess Token Sweep)          │ ~32,000 gas      │
└──────────────────────────────────────────────┴──────────────────┘
```

### Key Gas Optimization Drivers:
- **Slot 3 Packing**: Combining `reserve0`, `reserve1`, and `blockTimestampLast` saves **2,100 gas** per swap by avoiding a second `SLOAD`.
- **Custom Errors**: Using custom 4-byte selectors instead of revert strings saves over **80%** on execution failure paths.
