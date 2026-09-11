# 20 — Oracle Attack Laboratory: 9 Exploit Scenarios & Mitigations

## Master Oracle Threat Matrix & Defenses

```
┌──────────────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Attack Scenario                              │ Protocol Defense Mechanism                             │
├──────────────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ 1. Single-Block Flash Loan Manipulation      │ Flash loans have Δt = 0; zero weight on TWAP.          │
│ 2. Extreme Trade Price Distortion            │ Single swap only impacts future time-weighted interval.│
│ 3. Direct Reserve Donation Manipulation      │ Stored reserves isolate cumulative accumulators.       │
│ 4. Low-Liquidity Pool Manipulation           │ Protocol warning: TWAP requires TVL liquidity bounds.  │
│ 5. Long-Inactive Pool Timestamp Jump         │ Accumulator integrates full elapsed time accurately.   │
│ 6. Short-Window TWAP Distortion Attempt      │ Consumers enforce minimum lookback >= 1800s.           │
│ 7. Multi-Block Validator Withholding Attack  │ Cost to hold price across multiple blocks is immense.  │
│ 8. Token Decimal Mismatch Exploitation       │ Explicit decimal normalization in pricing math.        │
│ 9. Stale Observation / Zero History Query    │ Reverts with Uninitialized() or InsufficientHistory(). │
└──────────────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
