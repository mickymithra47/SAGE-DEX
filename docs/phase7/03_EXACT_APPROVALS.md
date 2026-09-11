# 03 — Exact-Amount Approvals vs Over-Authorization

## 1. The Exact Approval Pattern
- The user approves only the exact input amount needed for the immediate trade:
  `token.approve(router, exactAmount)`
- Once the swap executes, the allowance drops to `0`.

---

## 2. Tradeoffs

```
┌─────────────────────┬─────────────────────────────────┬─────────────────────────────────┐
│ Metric              │ Exact Approval                  │ Unlimited Approval              │
├─────────────────────┼─────────────────────────────────┼─────────────────────────────────┤
│ Security Exposure   │ Zero residual exposure          │ Full wallet balance exposed     │
│ Gas Efficiency      │ ~45,000 gas per subsequent swap │ 0 gas on subsequent swaps       │
│ User Experience     │ Requires 2 txs for every trade  │ 1 tx for subsequent trades      │
└─────────────────────┴─────────────────────────────────┴─────────────────────────────────┘
```
