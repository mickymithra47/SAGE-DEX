# 25 — Transaction Tracking & Block Confirmation Monitoring

## 1. Lifecycle Tracking
- Tracks `txHash`, block height, confirmation count, and receipt status.
- Automatically refreshes token balances and reserves upon receipt confirmation (`status === 'success'`).
