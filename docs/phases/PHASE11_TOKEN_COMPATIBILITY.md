# Phase 11 — Token Compatibility & Adversarial ERC-20 Matrix

## 1. Compatibility Matrix

| Token Behavior | Compatibility Status | Handling Rationale |
| :--- | :---: | :--- |
| **Standard ERC-20 (18 decimals)** | **Supported** | Full native support |
| **USDC / USDT (6 decimals)** | **Supported** | Scaled via multi-decimal math |
| **WBTC (8 decimals)** | **Supported** | Scaled via multi-decimal math |
| **Fee-On-Transfer Tokens** | **Supported** | Handled by pair balance-delta checks |
| **No-Return Value (USDT)** | **Supported** | Handled via SafeTokenTransfer Yul |
| **Rebasing Tokens** | **Supported** | Reconciled via `pair.sync()` |
| **Reentrant ERC-777 / 1363** | **Defended** | Blocked by pair reentrancy lock |
| **Reverting on 0 Transfer** | **Supported** | Zero transfers avoided in router |
