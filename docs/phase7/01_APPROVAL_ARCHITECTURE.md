# 01 — Token Authorization & Approval Architecture

## 1. The Multi-Tier Authorization Model

```
                         USER WALLET
                             │
                  ┌──────────┴──────────┐
                  │                     │
                  ▼                     ▼
             ERC-20 APPROVE        EIP-712 SIGNATURE
                  │                     │
                  │                ┌────▼────┐
                  │                │ Permit  │
                  │                │ /Permit2│
                  │                └────┬────┘
                  │                     │
                  └──────────┬──────────┘
                             ▼
                    AKIRA PERMIT ROUTER
                             │
                     ┌───────▼───────┐
                     │ SWAP EXECUTION │
                     └───────┬───────┘
                             ▼
                        AKIRA PAIR
                             │
                             ▼
                        ERC-20 TOKENS
```

---

## 2. Architectural Isolation Principle
- The authorization layer operates strictly upstream of swap routing.
- The core AMM pair, factory, pricing engine, and LP positions remain completely independent of signature logic.
