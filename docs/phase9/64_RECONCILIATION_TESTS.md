# 64 — State Reconciliation Test Verification

## 1. Mismatch Injection Verification
- When on-chain reserves match DB ($1000 : 2000$), reconciliation confirms `isConsistent: true`.
- When an intentional discrepancy is injected ($1000 : 2010$), reconciliation flags `isConsistent: false` and calculates exact delta of $10\text{ wei}$.
