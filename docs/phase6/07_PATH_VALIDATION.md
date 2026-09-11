# 07 — Route & Path Validation Matrix

## 1. Path Validation Checks

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Path Condition                        │ Behavior / Revert Trigger                              │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Path length < 2                       │ Reverts with InvalidPath()                             │
│ Zero address in path                  │ Reverts with PairNotFound()                            │
│ Consecutive identical tokens (A -> A) │ Reverts with PairNotFound()                            │
│ Non-existent pair                     │ Reverts with PairNotFound()                            │
│ Native ETH in non-boundary hop        │ Reverts with InvalidPath()                             │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
