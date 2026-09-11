# 34 — Router Approval Model & Allowance Lifecycle

## 1. Approval Architecture
```
Trader ──[ 1. approve(Router, amount) ]──> ERC-20 Token
Trader ──[ 2. swapExactTokensForTokens(...) ]──> Router ──[ 3. transferFrom(Trader, Pair, amount) ]──> Pair
```

---

## 2. Security Considerations
- The router only pulls tokens from `msg.sender` during active swap execution.
- Phase 7 will evaluate `Permit2` (Uniswap-style token authorization) and EIP-2612 permit meta-transactions.
