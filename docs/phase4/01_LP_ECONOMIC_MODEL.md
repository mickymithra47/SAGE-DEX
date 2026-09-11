# 01 — LP Economic Model & Proportional Pool Ownership

## 1. The Liquidity Provider Economic Relationship
A Liquidity Provider (LP) deposits paired assets into an AMM liquidity pool to facilitate continuous decentralized trading. In exchange, the LP receives **LP Shares**, which represent a fungible equity claim on the total underlying reserves.

```
┌─────────────────────────┬───────────────────────────────────────────────────────────────────────────┐
│ Metric                  │ Mathematical Definition                                                   │
├─────────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ Total Circulating LP    │ S_total = ∑ S_user + MINIMUM_LIQUIDITY (1000 locked to address(0))        │
│ User Ownership Fraction │ f = S_user / S_total                                                      │
│ Claimable Token0        │ Claim_0 = ⌊ (S_user × Reserve_0) / S_total ⌋                             │
│ Claimable Token1        │ Claim_1 = ⌊ (S_user × Reserve_1) / S_total ⌋                             │
└─────────────────────────┴───────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Floor Truncation & Rounding Guarantees
- In EVM arithmetic, calculating asset claims via integer division ($\lfloor \dots \rfloor$) always rounds down in favor of the pool.
- An LP can never redeem more assets than their exact proportional fraction of pool equity.
