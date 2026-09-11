# 36 — LP Operations Gas Profiling & Benchmarks

## Phase 4 Quantitative Gas Benchmarks

```
┌──────────────────────────────────────────────┬──────────────────┐
│ Operation                                    │ Gas Cost (Units) │
├──────────────────────────────────────────────┼──────────────────┤
│ SagePair.mint (Initial Liquidity + Lock)    │ ~115,000 gas     │
│ SagePair.mint (Subsequent Warm Deposit)     │ ~68,000 gas      │
│ SagePair.burn (Liquidity Withdrawal)        │ ~62,000 gas      │
│ SagePair.transfer (LP Share Transfer)       │ ~34,800 gas      │
│ SageLPAccountingEngine.getPosition (View)   │ ~24,200 gas      │
│ SageLPAccountingEngine.quoteAddLiquidity    │ ~18,100 gas      │
│ SageLPAccountingEngine.quoteRemoveLiquidity │ ~26,400 gas      │
└──────────────────────────────────────────────┴──────────────────┘
```
