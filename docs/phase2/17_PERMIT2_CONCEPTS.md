# 17 — Permit2 Conceptual Architecture & Shared Allowance Infrastructure

## 1. What is Permit2?
**Permit2** is a shared smart contract layer (pioneered by Uniswap) that introduces next-generation signature approvals and time-bound allowance management for **ANY ERC-20 token**, even tokens that do not natively implement EIP-2612 (e.g. WETH, USDT, DAI).

---

## 2. Architectural Comparison

```
Traditional DEX Router Flow:
User ──[ Approve Token A ]──> Router A (Infinite Allowance risk per protocol)
User ──[ Approve Token B ]──> Router B

Permit2 Architecture Flow:
User ──[ Approve Once: max ]──> Permit2 (Canonical Immutable Infrastructure)
                                   │
                                   ├── Signature Transfer (Single-use EIP-712 witness permit)
                                   └── Allowance Transfer (Expiring, scoped permissions)
                                   │
                                   ▼
                            Sage Universal Router
```

---

## 3. Key Capabilities Provided by Permit2
1. **Signature-Based Transfers for All Tokens**: Extends gasless permits to legacy tokens (like WETH and WBTC).
2. **Expiring Allowances**: Approvals automatically expire after a specified duration (e.g. 30 minutes), neutralizing long-term exposure.
3. **Batch Approvals**: Users can sign permits for multiple tokens simultaneously in a single wallet popup.
4. **Universal Spender Trust**: Users only grant persistent allowances to the immutable Permit2 contract, not to application-level routers that may be upgraded or replaced.
