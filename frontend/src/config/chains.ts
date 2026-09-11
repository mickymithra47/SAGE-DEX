/**
 * SAGE DEX — Multi-Chain Network Configuration
 * Phase 2: Networks & Token Configuration
 */

export type NetworkType = 'evm' | 'non-evm';

export interface NativeCurrency {
  name: string;
  symbol: string;
  decimals: number;
}

export interface ChainConfig {
  id: number;
  name: string;
  shortName: string;
  networkType: NetworkType;
  nativeCurrency: NativeCurrency;
  rpcUrlEnvKey: string;
  defaultRpcUrl: string;
  explorerUrl: string;
  logoUrl?: string;
  enabled: boolean;
  isTestnet: boolean;
  isV1Launch: boolean;
}

export const CHAINS: Record<number, ChainConfig> = {
  // 1. Ethereum Mainnet
  1: {
    id: 1,
    name: 'Ethereum Mainnet',
    shortName: 'Ethereum',
    networkType: 'evm',
    nativeCurrency: {
      name: 'Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_ETHEREUM',
    defaultRpcUrl: 'https://eth.llamarpc.com',
    explorerUrl: 'https://etherscan.io',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png',
    enabled: true,
    isTestnet: false,
    isV1Launch: true
  },

  // 2. Arbitrum One
  42161: {
    id: 42161,
    name: 'Arbitrum One',
    shortName: 'Arbitrum',
    networkType: 'evm',
    nativeCurrency: {
      name: 'Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_ARBITRUM',
    defaultRpcUrl: 'https://arb1.arbitrum.io/rpc',
    explorerUrl: 'https://arbiscan.io',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/info/logo.png',
    enabled: true,
    isTestnet: false,
    isV1Launch: true
  },

  // 3. Polygon PoS
  137: {
    id: 137,
    name: 'Polygon PoS',
    shortName: 'Polygon',
    networkType: 'evm',
    nativeCurrency: {
      name: 'POL',
      symbol: 'POL',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_POLYGON',
    defaultRpcUrl: 'https://polygon-rpc.com',
    explorerUrl: 'https://polygonscan.com',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/info/logo.png',
    enabled: true,
    isTestnet: false,
    isV1Launch: true
  },

  // 4. BNB Smart Chain
  56: {
    id: 56,
    name: 'BNB Smart Chain',
    shortName: 'BNB Chain',
    networkType: 'evm',
    nativeCurrency: {
      name: 'BNB',
      symbol: 'BNB',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_BNB',
    defaultRpcUrl: 'https://bsc-dataseed.binance.org',
    explorerUrl: 'https://bscscan.com',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/binance/info/logo.png',
    enabled: true,
    isTestnet: false,
    isV1Launch: true
  },

  // 5. Optimism Mainnet
  10: {
    id: 10,
    name: 'OP Mainnet',
    shortName: 'Optimism',
    networkType: 'evm',
    nativeCurrency: {
      name: 'Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_OPTIMISM',
    defaultRpcUrl: 'https://mainnet.optimism.io',
    explorerUrl: 'https://optimistic.etherscan.io',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/optimism/info/logo.png',
    enabled: true,
    isTestnet: false,
    isV1Launch: true
  },

  // Local Devnet / Anvil (for local testing & dev)
  31337: {
    id: 31337,
    name: 'Anvil Local Devnet',
    shortName: 'Anvil',
    networkType: 'evm',
    nativeCurrency: {
      name: 'Local Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_LOCAL',
    defaultRpcUrl: 'http://127.0.0.1:8545',
    explorerUrl: 'http://localhost:8545',
    enabled: true,
    isTestnet: true,
    isV1Launch: false
  },

  // Sepolia Testnet (for public testnet testing)
  11155111: {
    id: 11155111,
    name: 'Ethereum Sepolia Testnet',
    shortName: 'Sepolia',
    networkType: 'evm',
    nativeCurrency: {
      name: 'Sepolia Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrlEnvKey: 'VITE_RPC_SEPOLIA',
    defaultRpcUrl: 'https://ethereum-sepolia-rpc.publicnode.com',
    explorerUrl: 'https://sepolia.etherscan.io',
    enabled: true,
    isTestnet: true,
    isV1Launch: false
  },

  // Future Non-EVM Network: Solana (Separated & Disabled for V1)
  999999999: {
    id: 999999999,
    name: 'Solana (Future Non-EVM)',
    shortName: 'Solana',
    networkType: 'non-evm',
    nativeCurrency: {
      name: 'SOL',
      symbol: 'SOL',
      decimals: 9
    },
    rpcUrlEnvKey: 'VITE_RPC_SOLANA',
    defaultRpcUrl: 'https://api.mainnet-beta.solana.com',
    explorerUrl: 'https://explorer.solana.com',
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/solana/info/logo.png',
    enabled: false, // Disabled for V1 EVM launch
    isTestnet: false,
    isV1Launch: false
  }
};

/**
 * Initial 5 Active EVM Networks for SAGE DEX V1 Launch
 */
export const V1_EVM_CHAINS: readonly number[] = [1, 42161, 137, 56, 10] as const;

/**
 * All currently supported chain IDs in SAGE frontend (including local devnet)
 */
export const SUPPORTED_CHAINS: readonly number[] = [1, 42161, 137, 56, 10, 31337, 11155111] as const;

/**
 * Checks if a given chain ID is supported by SAGE DEX
 */
export function isSupportedChain(chainId: number): boolean {
  const config = CHAINS[chainId];
  return Boolean(config && config.enabled);
}

/**
 * Checks if a given chain ID is one of the initial 5 SAGE V1 EVM networks
 */
export function isV1EVMChain(chainId: number): boolean {
  const config = CHAINS[chainId];
  return Boolean(config && config.enabled && config.isV1Launch && config.networkType === 'evm');
}

/**
 * Retrieves the full configuration for a chain ID
 */
export function getChainConfig(chainId: number): ChainConfig | undefined {
  return CHAINS[chainId];
}

/**
 * Returns all active SAGE V1 EVM networks
 */
export function getV1EVMChains(): ChainConfig[] {
  return V1_EVM_CHAINS.map((id) => CHAINS[id]).filter((c): c is ChainConfig => c !== undefined);
}

/**
 * Returns all enabled chain configurations
 */
export function getAllEnabledChains(): ChainConfig[] {
  return Object.values(CHAINS).filter((c) => c.enabled);
}

/**
 * Resolves the RPC URL for a chain (env variable override -> default fallback)
 */
export function getRpcUrl(chainId: number): string {
  const config = CHAINS[chainId];
  if (!config) return '';

  if (typeof import.meta !== 'undefined' && (import.meta as any).env) {
    const envOverride = (import.meta as any).env[config.rpcUrlEnvKey];
    if (envOverride) return envOverride;
  }
  return config.defaultRpcUrl;
}

/**
 * Generates an explorer link for a transaction hash
 */
export function getExplorerTxUrl(chainId: number, txHash: string): string {
  const config = CHAINS[chainId];
  if (!config || !config.explorerUrl) return '';
  return `${config.explorerUrl.replace(/\/$/, '')}/tx/${txHash}`;
}

/**
 * Generates an explorer link for a contract/account address
 */
export function getExplorerAddressUrl(chainId: number, address: string): string {
  const config = CHAINS[chainId];
  if (!config || !config.explorerUrl) return '';
  return `${config.explorerUrl.replace(/\/$/, '')}/address/${address}`;
}
