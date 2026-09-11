# 26 — Protocol Error Decoding & Human-Readable Alerts

## 1. Custom Error Mappings

```
┌──────────────────────────────┬────────────────────────────────────────────────────────┐
│ On-Chain Error Selector      │ Human-Readable UI Alert                                │
├──────────────────────────────┼────────────────────────────────────────────────────────┤
│ Expired()                    │ Transaction Expired in mempool                         │
│ InsufficientOutput()         │ Slippage Tolerance Breached (Price moved)              │
│ ExcessiveInput()             │ Input Amount Exceeded maximum tolerance                │
│ PairNotFound()               │ Liquidity Pool Does Not Exist                          │
│ InvalidSignature()           │ Signature Verification Failed                          │
│ User Rejected Request        │ Signature / Transaction Cancelled                      │
└──────────────────────────────┴────────────────────────────────────────────────────────┘
```
