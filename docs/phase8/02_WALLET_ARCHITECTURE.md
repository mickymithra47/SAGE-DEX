# 02 — Wallet Connection Architecture & Reactive Account Lifecycle

## 1. Supported Connection Providers
- **Injected Wallets**: MetaMask, Coinbase Wallet, Rabby, Brave Wallet via `window.ethereum`.
- **EIP-6963 Multi-Injected Provider Discovery**: Detects multiple browser wallets concurrently without collision.

---

## 2. Reactive Event Listeners
```typescript
window.ethereum.on('accountsChanged', (accounts) => updateActiveAccount(accounts[0]));
window.ethereum.on('chainChanged', (chainIdHex) => handleChainSwitch(parseInt(chainIdHex, 16)));
window.ethereum.on('disconnect', () => resetWalletState());
```
