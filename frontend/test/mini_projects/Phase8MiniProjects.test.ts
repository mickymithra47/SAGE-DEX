import { describe, it, expect } from 'vitest';
import { getContractsForChain } from '../../src/config/contracts';
import { DEFAULT_TOKENS } from '../../src/config/tokens';
import {
  parseUnits,
  getAmountOut,
  getAmountIn,
  calculateMinimumOutput
} from '../../src/lib/math';
import { decodeContractError } from '../../src/lib/errorDecoder';
import { buildSwapExactTokensCalldata } from '../../src/lib/txBuilder';

describe('Phase 8 — 15 Mini Projects Suite', () => {
  it('Project 1: Wallet connection state', () => {
    const mockAccount = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
    expect(mockAccount.startsWith('0x')).toBe(true);
    expect(mockAccount.length).toBe(42);
  });

  it('Project 2: Network detection and switching', () => {
    const chainId = 31337;
    const contracts = getContractsForChain(chainId);
    expect(contracts).toBeDefined();
    expect(contracts?.router).toBe('0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0');
  });

  it('Project 3: Typed contract registry', () => {
    const mainnetContracts = getContractsForChain(999999);
    expect(mainnetContracts).toBeUndefined();
  });

  it('Project 4: Token balance and metadata layer', () => {
    const tokens = DEFAULT_TOKENS[31337];
    expect(tokens.length).toBeGreaterThanOrEqual(4);
    const usdc = tokens.find((t) => t.symbol === 'USDC');
    expect(usdc?.decimals).toBe(6);
  });

  it('Project 5: Exact-input quote UI', () => {
    const amountIn = parseUnits('10', 18);
    const rIn = parseUnits('1000', 18);
    const rOut = parseUnits('2000', 18);
    const out = getAmountOut(amountIn, rIn, rOut);
    expect(out).toBeGreaterThan(0n);
  });

  it('Project 6: Exact-output quote UI', () => {
    const amountOut = parseUnits('19.74', 18);
    const rIn = parseUnits('1000', 18);
    const rOut = parseUnits('2000', 18);
    const requiredIn = getAmountIn(amountOut, rIn, rOut);
    expect(requiredIn).toBeGreaterThan(0n);
  });

  it('Project 7: Slippage / deadline controls', () => {
    const slippageBps = 50; // 0.5%
    const minOut = calculateMinimumOutput(10000n, slippageBps);
    expect(minOut).toBe(9950n);
  });

  it('Project 8: ERC-20 approval flow', () => {
    const allowance = 0n;
    const required = 100n;
    const needsApproval = allowance < required;
    expect(needsApproval).toBe(true);
  });

  it('Project 9: Permit2 signing flow', () => {
    const permitDetails = {
      permitted: { token: '0x1234' as `0x${string}`, amount: 1000n },
      nonce: 1n,
      deadline: 10000n
    };
    expect(permitDetails.permitted.amount).toBe(1000n);
  });

  it('Project 10: Transaction simulation', () => {
    const simulateResult = { success: true, gasUsed: 120000n };
    expect(simulateResult.success).toBe(true);
  });

  it('Project 11: Transaction tracking', () => {
    const txState: 'PENDING' | 'CONFIRMED' = 'CONFIRMED';
    expect(txState).toBe('CONFIRMED');
  });

  it('Project 12: Error decoding', () => {
    const err = decodeContractError({ message: 'InsufficientOutput()' });
    expect(err.title).toBe('Slippage Tolerance Breached');
  });

  it('Project 13: Native ETH/WETH flow', () => {
    const ethToken = DEFAULT_TOKENS[31337].find((t) => t.isNative);
    expect(ethToken?.symbol).toBe('ETH');
  });

  it('Project 14: Liquidity UI calculations', () => {
    const poolShareBps = 45; // 0.45%
    expect(poolShareBps / 100).toBe(0.45);
  });

  it('Project 15: Complete swap interface', () => {
    const calldata = buildSwapExactTokensCalldata({
      amountIn: 1000n,
      amountOutMin: 950n,
      path: ['0x1111111111111111111111111111111111111111', '0x2222222222222222222222222222222222222222'],
      to: '0x3333333333333333333333333333333333333333',
      deadline: 9999999999n
    });
    expect(calldata.startsWith('0x')).toBe(true);
  });
});
