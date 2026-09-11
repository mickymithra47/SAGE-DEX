# 34 — End-to-End Swap Execution Flow

## 1. Step-by-Step Trader Flow

```
1. User connects wallet
2. Selects Token In (e.g. USDC) and Token Out (e.g. WETH)
3. Enters Input Amount (e.g. 1,000 USDC)
4. Frontend fetches on-chain quote (out: 0.50 WETH, impact: 0.25%)
5. Validates balance and allowance
6. If allowance missing: User approves (Exact / Unlimited) or signs Permit2
7. User reviews minimum received and executes swap
8. Frontend submits transaction to SagePermitRouter
9. Transaction confirms -> Balances refresh automatically
```
