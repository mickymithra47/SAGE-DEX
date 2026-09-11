/**
 * SAGE DEX — Centralized Multi-Chain Token Configuration
 * Phase 2: Networks & Token Configuration
 */

export interface ChainTokenDeployment {
  address: `0x${string}` | 'native';
  decimals: number;
  isNative?: boolean;
  verified: boolean;
  verificationNote?: string;
}

export interface TokenConfig {
  id: string;
  symbol: string;
  name: string;
  defaultDecimals: number;
  logoUrl?: string;
  deployments: Record<number, ChainTokenDeployment>;
}

export interface TokenMetadata {
  address: `0x${string}` | 'native';
  symbol: string;
  name: string;
  decimals: number;
  isNative: boolean;
  chainId: number;
  logoUrl?: string;
  verified: boolean;
  verificationNote?: string;
}

/**
 * Master Registry of Initial SAGE DEX Assets (10 Assets across Supported Chains)
 */
export const TOKEN_REGISTRY: Record<string, TokenConfig> = {
  // 1. ETH / Ether
  eth: {
    id: 'eth',
    symbol: 'ETH',
    name: 'Ether',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png',
    deployments: {
      1: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'Ethereum Mainnet native asset'
      },
      42161: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'Arbitrum One native gas asset'
      },
      10: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'OP Mainnet native gas asset'
      },
      137: {
        address: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Canonical PoS Wrapped Ether on Polygon'
      },
      56: {
        address: '0x2170Ed0880ac9A755fd29B2688956BD959F933F8',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Binance-Peg Ethereum Token on BNB Chain'
      },
      31337: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'Anvil local devnet native asset'
      },
      11155111: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'Sepolia testnet native asset'
      }
    }
  },

  // 2. USDC / USD Coin
  usdc: {
    id: 'usdc',
    symbol: 'USDC',
    name: 'USD Coin',
    defaultDecimals: 6,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png',
    deployments: {
      1: {
        address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDC (Circle) on Ethereum'
      },
      42161: {
        address: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDC on Arbitrum'
      },
      137: {
        address: '0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDC on Polygon'
      },
      56: {
        address: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
        decimals: 18,
        verified: true,
        verificationNote: 'Binance-Peg USD Coin (18 decimals on BNB Chain)'
      },
      10: {
        address: '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDC on Optimism'
      },
      31337: {
        address: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
        decimals: 6,
        verified: true,
        verificationNote: 'Local mock USDC'
      }
    }
  },

  // 3. USDT / Tether USD
  usdt: {
    id: 'usdt',
    symbol: 'USDT',
    name: 'Tether USD',
    defaultDecimals: 6,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png',
    deployments: {
      1: {
        address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical USDT on Ethereum'
      },
      42161: {
        address: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDT on Arbitrum'
      },
      137: {
        address: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical PoS USDT on Polygon'
      },
      56: {
        address: '0x55d398326f99059fF775485246999027B3197955',
        decimals: 18,
        verified: true,
        verificationNote: 'Binance-Peg BSC-USD (18 decimals on BNB Chain)'
      },
      10: {
        address: '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58',
        decimals: 6,
        verified: true,
        verificationNote: 'Canonical native USDT on Optimism'
      }
    }
  },

  // 4. WBTC / Wrapped BTC
  wbtc: {
    id: 'wbtc',
    symbol: 'WBTC',
    name: 'Wrapped BTC',
    defaultDecimals: 8,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599/logo.png',
    deployments: {
      1: {
        address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
        decimals: 8,
        verified: true,
        verificationNote: 'Canonical WBTC on Ethereum'
      },
      42161: {
        address: '0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f',
        decimals: 8,
        verified: true,
        verificationNote: 'Canonical WBTC on Arbitrum'
      },
      137: {
        address: '0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6',
        decimals: 8,
        verified: true,
        verificationNote: 'Canonical WBTC on Polygon'
      },
      56: {
        address: '0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c',
        decimals: 18,
        verified: true,
        verificationNote: 'Binance-Peg BTCB on BNB Chain (18 decimals)'
      },
      10: {
        address: '0x68f180fcCe6836688e9084f035309E29Bf0A2095',
        decimals: 8,
        verified: true,
        verificationNote: 'Canonical WBTC on Optimism'
      }
    }
  },

  // 5. BNB / Binance Coin
  bnb: {
    id: 'bnb',
    symbol: 'BNB',
    name: 'BNB',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/binance/info/logo.png',
    deployments: {
      56: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'BNB Smart Chain native gas asset'
      },
      1: {
        address: '0xB8c77482e45F1F44dE1745F52C74426C631bDD52',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Legacy ERC-20 BNB on Ethereum'
      }
    }
  },

  // 6. POL / Polygon (formerly MATIC)
  pol: {
    id: 'pol',
    symbol: 'POL',
    name: 'Polygon Ecosystem Token',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/info/logo.png',
    deployments: {
      137: {
        address: 'native',
        decimals: 18,
        isNative: true,
        verified: true,
        verificationNote: 'Polygon PoS native gas token (POL/MATIC)'
      },
      1: {
        address: '0x455e53C3640bAb131401b603AC3be09108b53707',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Canonical upgraded POL token contract on Ethereum L1'
      }
    }
  },

  // 7. AVAX / Avalanche
  avax: {
    id: 'avax',
    symbol: 'AVAX',
    name: 'Avalanche',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/avalanche/info/logo.png',
    deployments: {
      1: {
        address: '0x1ce0c2827e2ef14d5c4f29a091d735a204794041',
        decimals: 18,
        isNative: false,
        verified: false,
        verificationNote: 'Placeholder: requires official verification for Ethereum L1 representation'
      },
      56: {
        address: '0x1ce0c2827e2ef14d5c4f29a091d735a204794041',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Binance-Peg AVAX on BNB Chain'
      }
    }
  },

  // 8. ARB / Arbitrum
  arb: {
    id: 'arb',
    symbol: 'ARB',
    name: 'Arbitrum',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/info/logo.png',
    deployments: {
      42161: {
        address: '0x912CE59144191C1204E64559FE8253a0e49E6548',
        decimals: 18,
        verified: true,
        verificationNote: 'Canonical ARB governance token on Arbitrum One'
      },
      1: {
        address: '0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1',
        decimals: 18,
        verified: true,
        verificationNote: 'Canonical ARB token on Ethereum L1'
      }
    }
  },

  // 9. OP / Optimism
  op: {
    id: 'op',
    symbol: 'OP',
    name: 'Optimism',
    defaultDecimals: 18,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/optimism/info/logo.png',
    deployments: {
      10: {
        address: '0x4200000000000000000000000000000000000042',
        decimals: 18,
        verified: true,
        verificationNote: 'Canonical OP governance token on Optimism'
      },
      1: {
        address: '0x4200000000000000000000000000000000000042',
        decimals: 18,
        verified: false,
        verificationNote: 'Placeholder: requires verification for L1 OP representation'
      }
    }
  },

  // 10. SOL / Solana
  sol: {
    id: 'sol',
    symbol: 'SOL',
    name: 'Solana',
    defaultDecimals: 9,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/solana/info/logo.png',
    deployments: {
      999999999: {
        address: 'native',
        decimals: 9,
        isNative: true,
        verified: true,
        verificationNote: 'Native SOL on Solana (non-EVM network, disabled in V1)'
      },
      1: {
        address: '0xD31a59c85AE9D8edE1a0fcBa675170B6B5CF5fBF',
        decimals: 9,
        isNative: false,
        verified: true,
        verificationNote: 'Wormhole Bridged SOL on Ethereum'
      },
      56: {
        address: '0x570A5D26f7765Ecb712C0924E4De545B89fD43dF',
        decimals: 18,
        isNative: false,
        verified: true,
        verificationNote: 'Binance-Peg Solana Token on BNB Chain (18 decimals)'
      }
    }
  }
};

/**
 * Local devnet mock tokens preserved for test suite compatibility
 */
const LOCAL_DEVNET_TOKENS: TokenMetadata[] = [
  {
    address: 'native',
    symbol: 'ETH',
    name: 'Native Ether',
    decimals: 18,
    isNative: true,
    chainId: 31337,
    verified: true,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png'
  },
  {
    address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    symbol: 'WETH',
    name: 'Wrapped Ether',
    decimals: 18,
    isNative: false,
    chainId: 31337,
    verified: true,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png'
  },
  {
    address: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    symbol: 'USDC',
    name: 'USD Coin',
    decimals: 6,
    isNative: false,
    chainId: 31337,
    verified: true,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png'
  },
  {
    address: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    decimals: 18,
    isNative: false,
    chainId: 31337,
    verified: true,
    logoUrl: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B175474E89094C44Da98b954EedeAC495271d0F/logo.png'
  },
  {
    address: '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9',
    symbol: 'TKNA',
    name: 'Sage Alpha Token',
    decimals: 18,
    isNative: false,
    chainId: 31337,
    verified: true
  },
  {
    address: '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707',
    symbol: 'TKNB',
    name: 'Sage Beta Token',
    decimals: 18,
    isNative: false,
    chainId: 31337,
    verified: true
  }
];

/**
 * Returns all configured token metadata for a specific chain ID
 */
export function getTokensForChain(chainId: number): TokenMetadata[] {
  if (chainId === 31337) {
    return LOCAL_DEVNET_TOKENS;
  }

  const result: TokenMetadata[] = [];
  for (const token of Object.values(TOKEN_REGISTRY)) {
    const deployment = token.deployments[chainId];
    if (deployment) {
      result.push({
        address: deployment.address,
        symbol: token.symbol,
        name: token.name,
        decimals: deployment.decimals,
        isNative: Boolean(deployment.isNative),
        chainId,
        logoUrl: token.logoUrl,
        verified: deployment.verified,
        verificationNote: deployment.verificationNote
      });
    }
  }
  return result;
}

/**
 * Checks whether a token symbol or token ID is supported on a given chain
 */
export function isTokenSupportedOnChain(tokenSymbolOrId: string, chainId: number): boolean {
  const token = getTokenConfig(tokenSymbolOrId);
  if (!token) return false;
  return Boolean(token.deployments[chainId]);
}

/**
 * Retrieves the address of a token on a specific chain ('native' or 0x address)
 */
export function getTokenAddress(tokenSymbolOrId: string, chainId: number): string | undefined {
  const token = getTokenConfig(tokenSymbolOrId);
  if (!token || !token.deployments[chainId]) return undefined;
  return token.deployments[chainId].address;
}

/**
 * Retrieves the decimals of a token on a specific chain
 */
export function getTokenDecimals(tokenSymbolOrId: string, chainId: number): number | undefined {
  const token = getTokenConfig(tokenSymbolOrId);
  if (!token || !token.deployments[chainId]) return undefined;
  return token.deployments[chainId].decimals;
}

/**
 * Look up token config by symbol or id (case-insensitive)
 */
export function getTokenConfig(symbolOrId: string): TokenConfig | undefined {
  const key = symbolOrId.toLowerCase();
  if (TOKEN_REGISTRY[key]) return TOKEN_REGISTRY[key];
  return Object.values(TOKEN_REGISTRY).find(
    (t) => t.symbol.toLowerCase() === key || t.id.toLowerCase() === key
  );
}

/**
 * Checks if an asset address or symbol represents a native gas asset
 */
export function isNativeAsset(addressOrSymbol: string): boolean {
  const lower = addressOrSymbol.toLowerCase();
  if (lower === 'native' || lower === '0x0000000000000000000000000000000000000000') {
    return true;
  }
  return ['eth', 'bnb', 'pol', 'matic', 'sol', 'avax'].includes(lower);
}

/**
 * Returns all token configurations
 */
export function getAllConfiguredTokens(): TokenConfig[] {
  return Object.values(TOKEN_REGISTRY);
}

/**
 * Backward compatibility dictionary mapping chainId -> TokenMetadata[]
 */
export const DEFAULT_TOKENS: Record<number, TokenMetadata[]> = new Proxy(
  {},
  {
    get(_target, prop) {
      const chainId = Number(prop);
      if (isNaN(chainId)) return undefined;
      return getTokensForChain(chainId);
    }
  }
);
