# 29 — Reactive State Management & Component Decoupling

## 1. Domain-Specific State Slices
- **Wallet Slice**: Connection status, current account, active chain.
- **Token Slice**: Selected pair, input/output amounts, decimals, symbols.
- **Quote Slice**: Real-time output, price impact, minimum received, route.
- **Transaction Slice**: Active modal state, tx hash, error status.
