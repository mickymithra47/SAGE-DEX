# 53 — Critical vs Non-Critical Data Partitioning

## 1. Classification Matrix

```
┌──────────────────────────────────────────────┬──────────────────┬─────────────────────────────┐
│ Data Element                                 │ Authority Tier   │ Primary Source              │
├──────────────────────────────────────────────┼──────────────────┼─────────────────────────────┤
│ Execution Calldata & Parameters              │ CRITICAL         │ Client Local + EVM Contract │
│ Minimum Output (amountOutMin)                │ CRITICAL         │ Smart Contract              │
│ Current User Token Balances                  │ CRITICAL         │ On-Chain RPC eth_call       │
│ User Spend Allowances                        │ CRITICAL         │ On-Chain RPC eth_call       │
│ Historical Price Charts (OHLCV)              │ NON-CRITICAL     │ Indexer Database            │
│ 24-Hour Trading Volume                       │ NON-CRITICAL     │ Indexer Database            │
│ Historical Trade Logs                        │ NON-CRITICAL     │ Indexer Database            │
└──────────────────────────────────────────────┴──────────────────┴─────────────────────────────┘
```
