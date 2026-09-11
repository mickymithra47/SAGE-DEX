# Phase 11 — Frontend Web Security & Transaction Boundaries

## 1. Web Security Posture
- **Zero Key Custody**: The web app connects via standard EIP-1193 wallet providers (MetaMask, Coinbase Wallet, WalletConnect). Private keys never touch web application memory.
- **Client-Side Simulation**: Pre-flights transactions using `eth_estimateGas` and simulates execution before presenting confirmation prompts.
- **Integer Exactness**: Uses `bigint` for all token balance and allowance calculations, eliminating floating-point rounding bugs.
