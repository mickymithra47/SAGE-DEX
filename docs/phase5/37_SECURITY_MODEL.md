# 37 — Phase 5 Security Model & Comprehensive Threat Matrix

## Threat Classification & Hardened Mitigations

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Threat Category                       │ Protocol Defense Mechanism                             │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Spot Price Flash Loan Skew         │ TWAP averages across time; flash loan (Δt=0) has 0 wt. │
│ 2. Exact-Input Over-Disbursement      │ Floor division truncates outputs safely.               │
│ 3. Exact-Output Under-Funding         │ Ceiling division (+1 wei) guarantees invariant delta.  │
│ 4. Decimal Discrepancy Error          │ Standardized normalizeDecimals scaling.                │
│ 5. Uninitialized Oracle Queries       │ Reverts cleanly with Uninitialized() error.            │
│ 6. Storage Mutation via View Calls    │ Quoter & Oracle methods marked strictly view/pure.     │
│ 7. Cumulative Accumulator Overflow    │ Q112 scaling fits uint256 for hundreds of years.       │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
