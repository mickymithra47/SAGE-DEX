# 40 — Core vs Periphery Responsibilities

## 1. Separation of Concerns Matrix

```
┌───────────────────────────────────────┬──────────────────────┬──────────────────────┐
│ Protocol Responsibility               │ Core AMM Layer       │ Future Periphery     │
├───────────────────────────────────────┼──────────────────────┼──────────────────────┤
│ 1. Invariant Preservation (k)         │ MANDATORY (Core)     │ N/A                  │
│ 2. Stored Reserve Updates             │ MANDATORY (Core)     │ N/A                  │
│ 3. LP Token Mint & Burn               │ MANDATORY (Core)     │ N/A                  │
│ 4. Reentrancy Mutex Protection        │ MANDATORY (Core)     │ N/A                  │
│ 5. Pulling User Funds (transferFrom)  │ PROHIBITED           │ MANDATORY (Periphery)│
│ 6. User Slippage Bounds (amountMin)   │ PROHIBITED           │ MANDATORY (Periphery)│
│ 7. Transaction Deadlines              │ PROHIBITED           │ MANDATORY (Periphery)│
│ 8. Native ETH Wrapping / Unwrapping   │ PROHIBITED           │ MANDATORY (Periphery)│
└───────────────────────────────────────┴──────────────────────┴──────────────────────┘
```
