# 16 — Atomic State Transitions & Revert Guarantees

## 1. The Atomicity Principle
In EVM financial protocols, **atomicity** guarantees that an operation either completes in full with 100% valid state transitions or aborts completely, leaving zero side effects in contract storage.

---

## 2. All-or-Nothing Failure Modes in Sage AMM
```
┌───────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ Failure Trigger                       │ Revert Effect                                               │
├───────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ Invariant Violation (K Violation)     │ Entire swap rolls back; output tokens returned to pool.     │
│ Insufficient Liquidity Minted (<1000) │ Initial LP deposit reverts; no shares created.              │
│ Flash Swap Loan Not Repaid            │ Flash borrow rolls back; no assets leave pool.              │
│ Token Transfer Fails                  │ SafeTokenTransfer custom revert bubbles up atomically.      │
│ Mutex Reentrancy Attempt              │ Reverts with SagePair.Locked(); state remains protected.   │
└───────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
```
