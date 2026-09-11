# 26 — Access Control, Trust Minimization & Immutability

## 1. Access Control Topology
The Sage AMM V2 Core is designed to be as **permissionless, trust-minimized, and immutable** as technically possible.

```
┌─────────────────────────┬───────────────────────────────┬────────────────────────────────────────────────────────┐
│ Function                │ Authorization                 │ Security Rationale                                     │
├─────────────────────────┼───────────────────────────────┼────────────────────────────────────────────────────────┤
│ Factory.createPair      │ Permissionless (Anyone)       │ Allows open token pair creation at any time.           │
│ Factory.setFeeTo        │ Only `feeToSetter`            │ Admin address controlling protocol fee recipient.      │
│ Factory.setFeeToSetter  │ Only `feeToSetter`            │ Enables transfer of fee setter admin authority.        │
│ Pair.initialize         │ Only `factory` (once)         │ Configures token0 and token1 during deployment.        │
│ Pair.mint / burn / swap │ Permissionless (Anyone)       │ Open market operations accessible to all users/routers.│
│ Pair.skim / sync        │ Permissionless (Anyone)       │ Open reconciliation methods to sweep excess tokens.    │
└─────────────────────────┴───────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## 2. Zero Backdoors Guarantee
- Pair contracts have NO owner, NO administrative pause switches, NO upgradeable proxies, and NO ability for developers or protocol admins to withdraw liquidity pool reserves.
