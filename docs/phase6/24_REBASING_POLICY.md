# 24 — Rebasing Token Policy & Balance Invariance

## 1. Protocol Policy
- Positive or negative rebasing tokens (which change balances without transfer events) cause pool reserves to drift away from physical balances.
- Rebasing tokens must be wrapped into non-rebasing standard wrappers (e.g. `wstETH` for `stETH`) before pair creation and routing.
