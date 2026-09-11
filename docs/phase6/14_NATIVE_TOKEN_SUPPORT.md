# 14 — Native ETH Wrapping & Unwrapping Architecture

## 1. Native ETH Integration Matrix

```
┌─────────────────────────┬────────────────────────────────────────────────────────────────────────────┐
│ Swap Function           │ Native ETH Action                                                          │
├─────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
│ swapExactETHForTokens   │ Wraps msg.value -> WETH via deposit(), sends WETH to Pair(0,1).            │
│ swapTokensForExactETH   │ Routes into WETH, router unwraps via withdraw(amounts[last]), sends ETH.   │
│ swapExactTokensForETH   │ Routes into WETH, router unwraps via withdraw(amounts[last]), sends ETH.   │
│ swapETHForExactTokens   │ Wraps required amountIn -> WETH, refunds remaining msg.value - amountIn.   │
└─────────────────────────┴────────────────────────────────────────────────────────────────────────────┘
```
