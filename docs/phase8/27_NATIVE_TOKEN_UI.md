# 27 — Native ETH & WETH Wrapping UI Architecture

## 1. Seamless Native Integration
- Displays `ETH` as primary currency while internally resolving route boundaries to canonical `WETH`.
- Routes `ETH → Token` through `swapExactETHForTokens` with `msg.value`.
- Routes `Token → ETH` through `swapExactTokensForETH` with automatic unwrapping.
