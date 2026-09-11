# 06 — Token Permit Compatibility Matrix

## 1. Classification of ERC-20 Tokens

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Token Category                        │ Permit Capability & Protocol Handling                  │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Standard ERC-20 (USDT, legacy tokens) │ No permit support. Requires standard approve() tx.     │
│ EIP-2612 Compatible (USDC, DAI)       │ Supports standard permit(). Gasless approvals.         │
│ Non-Standard Permit (DAI legacy)      │ Uses custom permit(holder, spender, nonce, expiry, ...)│
│ Permit2 Compatible (All ERC-20s)      │ Uses Permit2 canonical contract. Universal permit.     │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
