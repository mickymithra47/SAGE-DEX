# 07 — Token Registry & Metadata Architecture

## 1. Default Token Configuration
- Maintains a curated whitelist of verified tokens with strict decimal specifications:
  - **USDC**: 6 decimals
  - **WBTC**: 8 decimals
  - **DAI / WETH / TKNA / TKNB**: 18 decimals

---

## 2. Dynamic Token Discovery
- User-entered custom contract addresses are verified on-chain via ERC-20 `symbol()`, `name()`, and `decimals()` before inclusion in the local selection state.
