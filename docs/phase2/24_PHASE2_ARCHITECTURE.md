# 24 — Phase 2 Architecture & Asset Layer Map

## Phase 2 Final Architecture Diagram

```
                                      USER / TRADER / LP
                                              │
                              ┌───────────────┴───────────────┐
                              │                               │
                          Native ETH                       ERC-20
                              │                               │
                              ▼                               ▼
                            WETH                        Token Contract
                         (Mint 1:1)                           │
                                              ┌───────────────┼───────────────┐
                                              ▼               ▼               ▼
                                           Balance        Allowance        Permit
                                          (balanceOf)    (allowance)    (EIP-2612)
                                              │               │               │
                                              └───────────────┼───────────────┘
                                                              │
                                                              ▼
                                               SafeTokenTransfer Library
                                              (Low-Level Assembly Wrapper)
                                                              │
                                                              ▼
                                            Token Accounting & Math Engine
                                            (18-Dec WAD Scaling / CEI / Delta)
                                                              │
                                                              ▼
                                                FUTURE DEX AMM PROTOCOL
                                             (PoolManager / Router / Pairs)
```

---

## Component Layout & Responsibilities
- `src/phase2/interfaces/`: Canonical definitions (`IERC20`, `IERC20Metadata`, `IERC20Permit`, `IWETH`).
- `src/phase2/token/`: Production ERC-20, WETH, PermitToken, DecimalsToken, TokenRegistry.
- `src/phase2/libraries/`: `SafeTokenTransfer`, `TokenAccountingMath`, `TokenCompatibilityChecker`.
- `src/phase2/mocks/`: 12 Adversarial and Malicious token mocks.
- `src/phase2/mini_projects/`: 8 self-contained Phase 2 mini-projects.
- `src/phase2/security_lab/`: 12 security vulnerability scenarios with exploit proofs and hardened fixes.
