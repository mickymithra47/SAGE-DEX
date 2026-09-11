# 24 — Transaction State Machine & Deterministic Transitions

## 1. State Machine Topology

```
 IDLE
  │
  ▼
 QUOTING
  │
  ▼
 APPROVAL_REQUIRED ──[ Approve Click ]──> APPROVAL_PENDING ──> APPROVAL_CONFIRMED
  │                                                                 │
  ▼                                                                 ▼
 SIGNING (Permit2 / Swap) ──────────────────────────────────> SUBMITTED
                                                                 │
                                                                 ▼
                                                              PENDING
                                                                 │
                                               ┌─────────────────┴─────────────────┐
                                               ▼                                   ▼
                                           CONFIRMED                             FAILED
```
