# SAGE DEX — Product & Engineering Roadmap

## Product Architecture Overview

* **Liquidity Source**: SAGE will NOT create its own liquidity pools initially. Instead, SAGE will aggregate and route through existing on-chain liquidity sources.
* **Fee Model**: SAGE charges a transparent **0.3%** swap fee on executed trades.
* **Quote Engine**: SAGE uses live, executable market quotes rather than hard-coded prices.
* **Slippage Protection**: Mandatory slippage tolerance boundaries, minimum output enforcement, and deadline protection on all swaps.
* **Supported Networks (Initial EVM Launch)**:
  1. Ethereum
  2. Arbitrum
  3. Polygon
  4. BNB Chain
  5. Optimism
* **Future Expansion**: Solana will be handled separately in a subsequent phase due to non-EVM execution differences.

---

## Phase Roadmap

### Phase 1 — Project & Architecture Setup
- Rebrand protocol and application from SAGE DEX to SAGE DEX.
- Maintain existing foundation, AMM libraries, and historical test harnesses.
- Establish clean workspace structure, TypeScript types, and repository conventions.

### Phase 2 — Networks & Token Configuration
- Configure multi-chain network parameters (RPC endpoints, chain IDs, block explorers).
- Establish verified token registries, metadata resolvers, and decimal normalizers for Ethereum, Arbitrum, Polygon, BNB Chain, and Optimism.

### Phase 3 — Quote Engine / Live Market Pricing
- Build off-chain and on-chain quote calculation engines.
- Connect to live on-chain reserve feeds and liquidity pools across supported chains for executable pricing.

### Phase 4 — Best Route & Liquidity Aggregation
- Implement smart routing algorithms (single-hop, multi-hop, split-routing) to find optimal trade paths with minimal price impact and slippage.

### Phase 5 — SAGE Router Smart Contract
- Deploy stateless, gas-optimized SAGE Router contract capable of executing aggregated trades across multiple DEX protocols with full reentrancy and callback security.

### Phase 6 — 0.3% Fee + Fee Management
- Implement transparent 0.3% protocol fee accrual and administration mechanisms.
- Establish fee recipient routing, fee-on-transfer protection, and withdrawal controls.

### Phase 7 — Slippage, Minimum Output & Deadline Protection
- Integrate strict parameter validation enforcing maximum slippage tolerance, `minAmountOut`, and block deadline limits to eliminate MEV sandwich vulnerabilities.

### Phase 8 — Swap Execution + Wallet Integration
- Build modern, responsive Web3 wallet connection workflows (MetaMask, Coinbase Wallet, WalletConnect).
- Implement EIP-2612 and Permit2 token approval abstractions for gasless or combined permit-and-swap transactions.

### Phase 9 — Gas, Price Impact, History & UI
- Deliver a state-of-the-art decentralized exchange UI with real-time gas estimation, price impact warnings, historical transaction tracking, and token search.

### Phase 10 — Security Testing → Testnet → Mainnet
- Comprehensive fuzz testing, formal verification, adversarial threat modeling, public testnet deployment, final security audits, and production mainnet launch.
