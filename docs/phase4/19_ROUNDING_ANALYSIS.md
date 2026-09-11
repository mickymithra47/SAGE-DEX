# 19 — Financial Rounding Directions & Precision Loss Defenses

## 1. Master Rounding Direction Matrix

```
┌───────────────────────────────────────┬────────────────────┬────────────────────────────────────────────────────────┐
│ Operation                             │ Rounding Direction │ Security Justification                                 │
├───────────────────────────────────────┼────────────────────┼────────────────────────────────────────────────────────┤
│ Initial Liquidity (sqrt)              │ Floor (Truncate)   │ Prevents minting unbacked fractional LP shares.        │
│ Subsequent LP Minting                 │ Floor (Truncate)   │ Pool retains fractional deposits; protects pool equity.│
│ Liquidity Burning (Redemption)        │ Floor (Truncate)   │ LP cannot withdraw fractional excess pool reserves.    │
│ Ownership Basis Points                │ Floor (Truncate)   │ Indexer view never reports >100.00% ownership.         │
│ Impermanent Loss Basis Points         │ Floor (Truncate)   │ Standard integer precision.                            │
└───────────────────────────────────────┴────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. No Free Value Extraction via Rounding
In `LPAttackLabTest` (`test_LPAttack17_RepeatedRoundingValueExtractionDefense`), 20 rapid round-trip deposit and burn operations prove that an attacker cannot systematically extract free tokens through rounding; net tokens returned are strictly $\le$ initial deposits.
