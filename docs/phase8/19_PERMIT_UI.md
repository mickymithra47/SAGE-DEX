# 19 — Gasless Permit & Permit2 Signing UI

## 1. Off-Chain Signature Flow
```
User clicks "Sign Permit2"
  ↓
Wallet prompts EIP-712 typed data signing (Token, Amount, Spender, Nonce, Deadline)
  ↓
User approves signature (0 gas paid)
  ↓
Frontend bundles signature into swapExactTokensForTokensWithPermit2 calldata
  ↓
User confirms single atomic transaction on-chain
```
