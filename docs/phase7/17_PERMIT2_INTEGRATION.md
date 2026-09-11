# 17 — Permit2 Integration Boundaries & Layer Isolation

## 1. Upstream Protocol Isolation
```
USER ──[ EIP-712 Signature ]──> PERMIT2 ──[ safeTransferFrom ]──> FIRST PAIR
                                    │
                              AKIRA ROUTER (Execution Coordinator)
```

- `SagePair`, `SageFactory`, `SagePricingLibrary`, and `SageOracleEngine` have **zero dependencies** on Permit2.
- The pair simply receives the tokens and verifies balance deltas during swap execution.
