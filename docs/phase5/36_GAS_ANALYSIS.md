# 36 — Pricing & Oracle Gas Consumption Profiles

## Phase 5 Quantitative Gas Benchmarks

```
┌──────────────────────────────────────────────┬──────────────────┐
│ Operation                                    │ Gas Cost (Units) │
├──────────────────────────────────────────────┼──────────────────┤
│ SageQuoter.quoteExactInputSingle (View)     │ ~26,800 gas      │
│ SageQuoter.quoteExactInputMultiHop (View)   │ ~53,500 gas      │
│ SageQuoter.getMinimumOutputAmount (Pure)    │ ~700 gas         │
│ SageOracleEngine.update (Storage Write)     │ ~48,000 gas      │
│ SageOracleEngine.consult (Lookback View)    │ ~41,100 gas      │
│ SageOracleEngine.getSpotPriceWad (View)     │ ~8,200 gas       │
└──────────────────────────────────────────────┴──────────────────┘
```
