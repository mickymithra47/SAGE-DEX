# 19 — TWAP Lookback Windows & Tradeoff Analysis

## 1. Tradeoff Matrix

```
┌─────────────────────┬───────────────────┬───────────────────┬────────────────────────────────────────────────┐
│ Window Duration     │ Price Lag / Delay │ Manipulation Cost │ Recommended Use Case                           │
├─────────────────────┼───────────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 1 Minute (60s)      │ Very Low          │ Low               │ Fast liquidations; volatile meme tokens.       │
│ 5 Minutes (300s)    │ Low               │ Moderate          │ Active decentralized lending protocols.        │
│ 30 Minutes (1800s)  │ Moderate          │ High              │ Collateral pricing; stablecoin pegs.           │
│ 1 Hour (3600s)      │ High              │ Very High         │ Conservative benchmark valuations.             │
│ 24 Hours (86400s)   │ Very High         │ Maximum           │ Governance asset voting power / minting caps.  │
└─────────────────────┴───────────────────┴───────────────────┴────────────────────────────────────────────────┘
```
