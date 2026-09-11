# 02 — LP Share Representation: Architecture Selection & Rationale

## 1. Architectural Tradeoff Analysis

```
┌───────────────────────────────────────┬──────────────┬──────────────┬──────────────┐
│ Criteria                              │ Option A:    │ Option B:    │ Option C:    │
│                                       │ ERC-20 Token │ Internal Map │ Separate NFT │
├───────────────────────────────────────┼──────────────┼──────────────┼──────────────┤
│ 1. DeFi Composability                 │ MAXIMUM      │ NONE         │ MODERATE     │
│ 2. Gas Efficiency on Mint/Burn        │ HIGH         │ MAXIMUM      │ LOW          │
│ 3. Transferability & Secondary Market │ NATIVE       │ IMPOSSIBLE   │ NATIVE       │
│ 4. Off-Chain Indexing & Standard APIs │ UNIVERSAL    │ COMPLEX      │ CUSTOM       │
│ 5. Audit Surface & Formal Proofs      │ MINIMAL      │ MINIMAL      │ COMPLEX      │
└───────────────────────────────────────┴──────────────┴──────────────┴──────────────┘
```

---

## 2. Decision: Option A (Fungible ERC-20 LP Token)
The SAGE Protocol selects **Option A** (`SageERC20` with EIP-2612 permit).
- **Full Range Uniformity**: In constant-product AMMs ($x \cdot y = k$), all liquidity covers the full price range ($0 \to \infty$). Thus, all LP positions are economically fungible.
- **ERC-20 Standard**: Allows LP positions to be staked in farms, used as lending collateral, and transferred seamlessly across wallets.
