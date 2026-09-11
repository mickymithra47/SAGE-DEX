# Phase 11 — Threat Model & Attacker Capabilities

## 1. Attacker Matrix & Capability Analysis

```
┌─────────────┬─────────────────────────────────┬───────────────────────────────┬────────────────────────┐
│ Attacker ID │ Attacker Profile                │ Capabilities                  │ Protocol Defense       │
├─────────────┼─────────────────────────────────┼───────────────────────────────┼────────────────────────┤
│ ATTACKER A  │ External EOA Wallet             │ Arbitrary calldata, frontrun  │ Slippage & deadline    │
│ ATTACKER B  │ Malicious ERC-20 Token          │ Reentrant hooks, fee-on-tx    │ Mutex lock, bal deltas │
│ ATTACKER C  │ Malicious Contract              │ Flash loan attacks, griefing  │ Invariant check, TWAP  │
│ ATTACKER D  │ Malicious Liquidity Provider    │ First-liquidity inflation     │ MINIMUM_LIQUIDITY lock │
│ ATTACKER E  │ Malicious Trader                │ Zero-input extraction         │ Strict balance check   │
│ ATTACKER F  │ Compromised Frontend            │ Spoofed UI parameters         │ Hardware wallet review │
│ ATTACKER G  │ Compromised RPC Node            │ Reorg injection, stale data   │ Ancestor check, reorgs │
│ ATTACKER H  │ MEV Searcher / Sandwicher       │ Priority gas auction          │ Client slippage min    │
│ ATTACKER I  │ Malicious Flash Swap Callee     │ Reentrant execution callback  │ Transient mutex lock   │
│ ATTACKER J  │ Malicious Nonce Replayer        │ Permit2 signature replay      │ Bitmap unordered nonce │
└─────────────┴─────────────────────────────────┴───────────────────────────────┴────────────────────────┘
```
