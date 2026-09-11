import { describe, it, expect } from 'vitest';
import {
  CHAINS,
  isSupportedChain,
  isV1EVMChain,
  getChainConfig,
  getV1EVMChains,
  getRpcUrl,
  getExplorerTxUrl,
  getExplorerAddressUrl
} from '../../src/config/chains';
import {
  getTokensForChain,
  isTokenSupportedOnChain,
  getTokenAddress,
  getTokenDecimals,
  getTokenConfig,
  isNativeAsset,
  getAllConfiguredTokens
} from '../../src/config/tokens';

describe('SAGE DEX — Phase 2: Networks & Token Configuration Suite', () => {
  // Test 1: All five EVM networks exist
  it('Requirement 1: All 5 initial EVM V1 networks are configured and enabled', () => {
    const v1Chains = getV1EVMChains();
    expect(v1Chains.length).toBe(5);

    const v1Ids = v1Chains.map((c) => c.id);
    expect(v1Ids).toContain(1); // Ethereum Mainnet
    expect(v1Ids).toContain(42161); // Arbitrum One
    expect(v1Ids).toContain(137); // Polygon PoS
    expect(v1Ids).toContain(56); // BNB Smart Chain
    expect(v1Ids).toContain(10); // OP Mainnet

    v1Chains.forEach((chain) => {
      expect(chain.enabled).toBe(true);
      expect(chain.networkType).toBe('evm');
      expect(chain.isV1Launch).toBe(true);
      expect(chain.nativeCurrency.symbol).toBeTruthy();
      expect(chain.defaultRpcUrl).toBeTruthy();
      expect(chain.explorerUrl).toBeTruthy();
    });
  });

  // Test 2: Chain IDs are unique
  it('Requirement 2: All configured chain IDs are distinct and unique', () => {
    const allChains = Object.values(CHAINS);
    const ids = allChains.map((c) => c.id);
    const uniqueIds = new Set(ids);
    expect(ids.length).toBe(uniqueIds.size);
  });

  // Test 3: Supported-chain lookup works
  it('Requirement 3: Supported chain lookup correctly identifies active networks', () => {
    expect(isSupportedChain(1)).toBe(true);
    expect(isSupportedChain(42161)).toBe(true);
    expect(isSupportedChain(137)).toBe(true);
    expect(isSupportedChain(56)).toBe(true);
    expect(isSupportedChain(10)).toBe(true);
    expect(isSupportedChain(31337)).toBe(true); // Local devnet

    expect(isV1EVMChain(1)).toBe(true);
    expect(isV1EVMChain(42161)).toBe(true);
    expect(isV1EVMChain(137)).toBe(true);
    expect(isV1EVMChain(56)).toBe(true);
    expect(isV1EVMChain(10)).toBe(true);
    expect(isV1EVMChain(31337)).toBe(false); // Devnet is not a V1 production chain
  });

  // Test 4: Unsupported chain lookup is handled safely
  it('Requirement 4: Unsupported chain IDs and disabled networks are handled safely', () => {
    expect(isSupportedChain(999999)).toBe(false);
    expect(isSupportedChain(0)).toBe(false);
    expect(isSupportedChain(-1)).toBe(false);
    expect(getChainConfig(999999)).toBeUndefined();

    // Solana is configured as non-EVM and disabled for V1
    const solanaConfig = getChainConfig(999999999);
    expect(solanaConfig).toBeDefined();
    expect(solanaConfig?.networkType).toBe('non-evm');
    expect(solanaConfig?.enabled).toBe(false);
    expect(isSupportedChain(999999999)).toBe(false);
  });

  // Test 5: Required token metadata exists
  it('Requirement 5: All 10 required tokens exist in registry with metadata', () => {
    const requiredSymbols = ['ETH', 'USDC', 'USDT', 'WBTC', 'BNB', 'POL', 'AVAX', 'ARB', 'OP', 'SOL'];
    const allTokens = getAllConfiguredTokens();
    const configuredSymbols = allTokens.map((t) => t.symbol);

    requiredSymbols.forEach((symbol) => {
      expect(configuredSymbols).toContain(symbol);
      const token = getTokenConfig(symbol);
      expect(token).toBeDefined();
      expect(token?.name).toBeTruthy();
      expect(token?.defaultDecimals).toBeGreaterThan(0);
      expect(Object.keys(token?.deployments || {}).length).toBeGreaterThan(0);
    });
  });

  // Test 6: Native assets are correctly identified
  it('Requirement 6: Native assets and ERC-20 tokens are accurately distinguished', () => {
    expect(isNativeAsset('native')).toBe(true);
    expect(isNativeAsset('0x0000000000000000000000000000000000000000')).toBe(true);
    expect(isNativeAsset('ETH')).toBe(true);
    expect(isNativeAsset('BNB')).toBe(true);
    expect(isNativeAsset('POL')).toBe(true);

    const ethConfig = getTokenConfig('ETH');
    expect(ethConfig?.deployments[1].isNative).toBe(true);
    expect(ethConfig?.deployments[1].address).toBe('native');
    expect(ethConfig?.deployments[42161].isNative).toBe(true);

    const bnbConfig = getTokenConfig('BNB');
    expect(bnbConfig?.deployments[56].isNative).toBe(true);
    expect(bnbConfig?.deployments[1].isNative).toBe(false); // ERC20 on Ethereum

    const usdcConfig = getTokenConfig('USDC');
    expect(usdcConfig?.deployments[1].isNative).toBeFalsy();
    expect(usdcConfig?.deployments[1].address.startsWith('0x')).toBe(true);
  });

  // Test 7: Chain-specific token lookup works
  it('Requirement 7: Chain-specific token lookups return correct addresses', () => {
    // USDC on Ethereum vs Arbitrum vs Polygon
    const ethUsdc = getTokenAddress('USDC', 1);
    const arbUsdc = getTokenAddress('USDC', 42161);
    const polyUsdc = getTokenAddress('USDC', 137);

    expect(ethUsdc).toBe('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
    expect(arbUsdc).toBe('0xaf88d065e77c8cC2239327C5EDb3A432268e5831');
    expect(polyUsdc).toBe('0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359');
    expect(ethUsdc).not.toBe(arbUsdc);

    // Tokens on Ethereum Mainnet
    const ethTokens = getTokensForChain(1);
    expect(ethTokens.length).toBeGreaterThanOrEqual(8);
    const symbols = ethTokens.map((t) => t.symbol);
    expect(symbols).toContain('ETH');
    expect(symbols).toContain('USDC');
    expect(symbols).toContain('USDT');
    expect(symbols).toContain('WBTC');
  });

  // Test 8: Unsupported token/network combinations are rejected safely
  it('Requirement 8: Unsupported token/chain combinations safely return false/undefined', () => {
    // ARB is on Arbitrum & Ethereum, but not on Solana
    expect(isTokenSupportedOnChain('ARB', 42161)).toBe(true);
    expect(isTokenSupportedOnChain('ARB', 1)).toBe(true);
    expect(isTokenSupportedOnChain('ARB', 999999)).toBe(false);
    expect(getTokenAddress('ARB', 999999)).toBeUndefined();

    // Unknown token lookup
    expect(isTokenSupportedOnChain('NON_EXISTENT_COIN', 1)).toBe(false);
    expect(getTokenAddress('NON_EXISTENT_COIN', 1)).toBeUndefined();
    expect(getTokenConfig('NON_EXISTENT_COIN')).toBeUndefined();
  });

  // Test 9: Token decimals are correctly represented across chains
  it('Requirement 9: Token decimals reflect accurate chain-specific representations', () => {
    // USDC: 6 decimals on Ethereum/Arbitrum/Polygon/Optimism, 18 decimals on BNB Chain
    expect(getTokenDecimals('USDC', 1)).toBe(6);
    expect(getTokenDecimals('USDC', 42161)).toBe(6);
    expect(getTokenDecimals('USDC', 137)).toBe(6);
    expect(getTokenDecimals('USDC', 10)).toBe(6);
    expect(getTokenDecimals('USDC', 56)).toBe(18);

    // WBTC: 8 decimals on Ethereum/Arbitrum/Polygon/Optimism, 18 decimals on BNB Chain
    expect(getTokenDecimals('WBTC', 1)).toBe(8);
    expect(getTokenDecimals('WBTC', 42161)).toBe(8);
    expect(getTokenDecimals('WBTC', 56)).toBe(18);

    // SOL: 9 decimals on Solana & Ethereum Wormhole bridge
    expect(getTokenDecimals('SOL', 999999999)).toBe(9);
    expect(getTokenDecimals('SOL', 1)).toBe(9);
  });

  // Test 10: Utility and URL helpers
  it('Requirement 10: Explorer and RPC URL helpers work correctly', () => {
    const ethTxUrl = getExplorerTxUrl(1, '0x123abc');
    expect(ethTxUrl).toBe('https://etherscan.io/tx/0x123abc');

    const arbAddrUrl = getExplorerAddressUrl(42161, '0x456def');
    expect(arbAddrUrl).toBe('https://arbiscan.io/address/0x456def');

    const ethRpc = getRpcUrl(1);
    expect(ethRpc.startsWith('http')).toBe(true);
  });
});
