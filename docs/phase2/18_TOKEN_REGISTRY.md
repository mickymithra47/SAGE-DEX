# 18 — Token Registry Design: On-Chain State vs Off-Chain Metadata

## 1. The Role of a Token Registry
A **Token Registry** serves as an index and verification layer for assets traded within the Sage ecosystem.

---

## 2. The Golden Rule of DeFi Registries

> [!CAUTION]
> **A TOKEN REGISTRY MUST NEVER BECOME THE SOURCE OF TRUTH FOR TOKEN BALANCES OR TRANSFERS.**
>
> On-chain smart contract state inside the individual token contract (`balanceOf[account]`) remains the sole, authoritative source of truth. The registry exists strictly to index metadata (name, symbol, decimals) and record security categorization.

---

## 3. On-Chain vs Off-Chain Data Separation

```
+────────────────────────────────────────────+────────────────────────────────────────────+
| On-Chain Token Registry                    | Off-Chain Token Lists & Indexers           |
+────────────────────────────────────────────+────────────────────────────────────────────+
| - Token contract address                   | - High-res SVG / PNG logos                 |
| - Verified on-chain decimals               | - Coingecko / CoinMarketCap API links      |
| - Security Classification (Categories A–F) | - Social links, website, audit reports     |
| - Protocol Verification Status             | - Community spam / phishing blacklists     |
+────────────────────────────────────────────+────────────────────────────────────────────+
```
