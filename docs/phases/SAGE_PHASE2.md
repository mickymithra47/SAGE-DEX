# SAGE DEX — Phase 2: Networks & Token Configuration

## Overview
Phase 2 establishes the centralized multi-chain configuration foundation for **SAGE DEX**. It provides a robust, strongly typed architecture for managing supported blockchain networks, native currencies, token registries, multi-chain deployments, and validation helpers.

---

## 1. Supported Networks (Initial EVM V1 Launch)

SAGE DEX V1 is configured for five primary EVM networks plus development/testing environments:

| Network Name | Chain ID | Short Name | Native Currency | Network Type | V1 Launch Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Ethereum Mainnet** | `1` | `Ethereum` | `ETH` (18 dec) | `evm` | **Active V1** |
| **Arbitrum One** | `42161` | `Arbitrum` | `ETH` (18 dec) | `evm` | **Active V1** |
| **Polygon PoS** | `137` | `Polygon` | `POL` (18 dec) | `evm` | **Active V1** |
| **BNB Smart Chain** | `56` | `BNB Chain` | `BNB` (18 dec) | `evm` | **Active V1** |
| **OP Mainnet** | `10` | `Optimism` | `ETH` (18 dec) | `evm` | **Active V1** |
| **Anvil Devnet** | `31337` | `Anvil` | `ETH` (18 dec) | `evm` | Local Devnet |
| **Sepolia Testnet** | `11155111` | `Sepolia` | `ETH` (18 dec) | `evm` | Public Testnet |

### Solana Distinction (Non-EVM)
* **Solana** (`999999999`) is explicitly configured as `networkType: "non-evm"` and `enabled: false`.
* Solana transaction, wallet, and swap execution logic are completely separated and deferred to a future phase.

---

## 2. Supported Assets & Multi-Chain Registry

The master token registry (`frontend/src/config/tokens.ts`) configures the 10 initial assets across supported networks:

| Asset | Name | Native Chains | Multi-Chain Decimals | Verification Status |
| :--- | :--- | :--- | :--- | :--- |
| **ETH** | Ether | Ethereum (1), Arbitrum (42161), Optimism (10) | 18 | **Verified Canonical** on all chains |
| **USDC** | USD Coin | Multi-chain ERC-20 | 6 (ETH, ARB, POLY, OP), 18 (BSC) | **Verified Canonical** on all chains |
| **USDT** | Tether USD | Multi-chain ERC-20 | 6 (ETH, ARB, POLY, OP), 18 (BSC) | **Verified Canonical** on all chains |
| **WBTC** | Wrapped BTC | Multi-chain ERC-20 | 8 (ETH, ARB, POLY, OP), 18 (BSC) | **Verified Canonical** on all chains |
| **BNB** | BNB | BNB Smart Chain (56) | 18 | **Verified Canonical** (Native on BSC, ERC-20 on ETH) |
| **POL** | Polygon Token | Polygon PoS (137) | 18 | **Verified Canonical** (Native on Polygon, ERC-20 on ETH) |
| **AVAX** | Avalanche | Non-native on EVM V1 | 18 | **Verified** on BSC; L1 placeholder flagged |
| **ARB** | Arbitrum | Multi-chain ERC-20 | 18 | **Verified Canonical** on Arbitrum & Ethereum |
| **OP** | Optimism | Multi-chain ERC-20 | 18 | **Verified Canonical** on Optimism; L1 placeholder flagged |
| **SOL** | Solana | Native on Solana (disabled) | 9 (Solana, ETH Wormhole), 18 (BSC) | **Verified** Wormhole / Binance-Peg deployments |

---

## 3. Native vs ERC-20 Asset Representation

To ensure safety and avoid treating native gas assets as contract addresses:
- Native assets use `address: "native"` and `isNative: true`.
- Zero address (`0x0000000000000000000000000000000000000000`) and `"native"` are recognized by `isNativeAsset()`.
- Wrapped tokens (e.g., WETH, WBNB, WPOL) and bridge tokens (e.g., Binance-Peg, Wormhole) use their actual contract addresses.

---

## 4. Configuration Architecture & Reusable Helpers

Configuration files located in `frontend/src/config/`:
- `chains.ts`: Chain definitions, RPC env overrides, explorer URL builders, and chain validation.
- `tokens.ts`: Master token registry, multi-chain deployment lookups, and decimal normalizers.
- `contracts.ts`: Core protocol contract addresses per network.

### Key Validation Helpers:
- `isSupportedChain(chainId: number): boolean`
- `isV1EVMChain(chainId: number): boolean`
- `getChainConfig(chainId: number): ChainConfig | undefined`
- `getV1EVMChains(): ChainConfig[]`
- `getRpcUrl(chainId: number): string`
- `getTokensForChain(chainId: number): TokenMetadata[]`
- `isTokenSupportedOnChain(symbolOrId: string, chainId: number): boolean`
- `getTokenAddress(symbolOrId: string, chainId: number): string | undefined`
- `getTokenDecimals(symbolOrId: string, chainId: number): number | undefined`
- `isNativeAsset(addressOrSymbol: string): boolean`

---

## 5. Environment Variables Configuration

Updated in `.env.example`:
```bash
# SAGE V1 EVM Multi-Chain RPC Configuration
VITE_RPC_ETHEREUM=https://eth.llamarpc.com
VITE_RPC_ARBITRUM=https://arb1.arbitrum.io/rpc
VITE_RPC_POLYGON=https://polygon-rpc.com
VITE_RPC_BNB=https://bsc-dataseed.binance.org
VITE_RPC_OPTIMISM=https://mainnet.optimism.io
VITE_RPC_LOCAL=http://127.0.0.1:8545
VITE_RPC_SEPOLIA=https://ethereum-sepolia-rpc.publicnode.com
```

---

## 6. Testing & Build Verification

- **Frontend Vitest Suite** (`npm test`): **35 passed (35 total)** across 4 test files (including 10 new Phase 2 test suites).
- **TypeScript & Production Build** (`npm run build`): Clean build, 0 errors.
- **Foundry Smart Contract Test Suite** (`forge test`): **204 passed, 0 failed** across 58 test suites.
- **Indexer Mini-Projects Suite** (`npm test`): **20 passed, 0 failed** (100% green).
