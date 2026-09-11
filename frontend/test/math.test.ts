import { describe, it, expect } from 'vitest';
import {
  parseUnits,
  formatUnits,
  getAmountOut,
  getAmountIn,
  calculatePriceImpactBps,
  calculateMinimumOutput,
  calculateMaximumInput
} from '../src/lib/math';

describe('Phase 8 Math Library (Exact BigInt)', () => {
  it('parses token decimals without precision loss', () => {
    expect(parseUnits('1.5', 6)).toBe(1500000n);
    expect(parseUnits('1.5', 18)).toBe(1500000000000000000n);
    expect(parseUnits('0.000001', 6)).toBe(1n);
  });

  it('formats token decimals correctly', () => {
    expect(formatUnits(1500000n, 6)).toBe('1.5');
    expect(formatUnits(1500000000000000000n, 18)).toBe('1.5');
    expect(formatUnits(1n, 6)).toBe('0.000001');
  });

  it('calculates exact-input constant-product quote', () => {
    // 10 in, pool 1000 : 2000
    const out = getAmountOut(10n * 10n ** 18n, 1000n * 10n ** 18n, 2000n * 10n ** 18n);
    expect(out).toBe(19743160687941225977n); // ~19.74
  });

  it('calculates exact-output constant-product quote', () => {
    const amountOut = 19743160687941225977n;
    const requiredIn = getAmountIn(amountOut, 1000n * 10n ** 18n, 2000n * 10n ** 18n);
    expect(requiredIn).toBe(10000000000000000000n); // exact 10.0
  });

  it('calculates slippage bounds', () => {
    const amountOut = 10000n;
    const minOut = calculateMinimumOutput(amountOut, 50); // 0.5%
    expect(minOut).toBe(9950n);

    const amountIn = 10000n;
    const maxIn = calculateMaximumInput(amountIn, 50);
    expect(maxIn).toBe(10050n);
  });

  it('calculates price impact accurately', () => {
    const impact = calculatePriceImpactBps(
      10n * 10n ** 18n,
      19743152643194954305n,
      1000n * 10n ** 18n,
      2000n * 10n ** 18n
    );
    expect(impact).toBeGreaterThanOrEqual(120); // ~1.28%
  });
});
