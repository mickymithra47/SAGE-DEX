/**
 * @file math.ts
 * @notice Integer-exact BigInt mathematical utilities for SAGE DEX frontend.
 *         Ensures zero JavaScript floating-point truncation on blockchain token values.
 */

export function parseUnits(value: string, decimals: number): bigint {
  if (!value || value.trim() === '') return 0n;
  const cleanValue = value.trim();
  if (cleanValue.startsWith('-')) throw new Error('Negative amount not allowed');

  const parts = cleanValue.split('.');
  if (parts.length > 2) throw new Error('Invalid decimal number');

  const whole = parts[0] || '0';
  let fraction = parts[1] || '';

  if (fraction.length > decimals) {
    throw new Error(`Too many decimal places (maximum ${decimals})`);
  }

  while (fraction.length < decimals) {
    fraction += '0';
  }

  const combined = whole === '0' ? fraction : whole + fraction;
  return BigInt(combined);
}

export function formatUnits(value: bigint, decimals: number, maxDisplayDecimals: number = 6): string {
  const isNegative = value < 0n;
  const absoluteValue = isNegative ? -value : value;

  const divisor = 10n ** BigInt(decimals);
  const wholePart = absoluteValue / divisor;
  const fractionPart = absoluteValue % divisor;

  if (fractionPart === 0n) {
    return (isNegative ? '-' : '') + wholePart.toString();
  }

  let fractionStr = fractionPart.toString().padStart(decimals, '0');
  // Trim trailing zeroes
  fractionStr = fractionStr.replace(/0+$/, '');

  if (fractionStr.length > maxDisplayDecimals) {
    fractionStr = fractionStr.slice(0, maxDisplayDecimals);
  }

  return (isNegative ? '-' : '') + `${wholePart.toString()}.${fractionStr}`;
}

export function getAmountOut(amountIn: bigint, reserveIn: bigint, reserveOut: bigint): bigint {
  if (amountIn <= 0n || reserveIn <= 0n || reserveOut <= 0n) return 0n;
  const amountInWithFee = amountIn * 997n;
  const numerator = amountInWithFee * reserveOut;
  const denominator = reserveIn * 1000n + amountInWithFee;
  return numerator / denominator;
}

export function getAmountIn(amountOut: bigint, reserveIn: bigint, reserveOut: bigint): bigint {
  if (amountOut <= 0n || reserveIn <= 0n || reserveOut <= 0n || amountOut >= reserveOut) return 0n;
  const numerator = reserveIn * amountOut * 1000n;
  const denominator = (reserveOut - amountOut) * 997n;
  return (numerator / denominator) + 1n;
}

export function calculatePriceImpactBps(
  amountIn: bigint,
  amountOut: bigint,
  reserveIn: bigint,
  reserveOut: bigint
): number {
  if (amountIn <= 0n || reserveIn <= 0n || reserveOut <= 0n) return 0;

  // spotRate = (reserveOut * 1e18) / reserveIn
  // realizedRate = (amountOut * 1e18) / amountIn
  // impactBps = ((spotRate - realizedRate) * 10000) / spotRate
  const precision = 10n ** 18n;
  const spotRate = (reserveOut * precision) / reserveIn;
  const realizedRate = (amountOut * precision) / amountIn;

  if (realizedRate >= spotRate) return 0;

  const delta = spotRate - realizedRate;
  const impactBps = Number((delta * 10000n) / spotRate);
  return Math.min(Math.max(impactBps, 0), 10000);
}

export function calculateMinimumOutput(amountOut: bigint, slippageBps: number): bigint {
  const factor = 10000n - BigInt(slippageBps);
  return (amountOut * factor) / 10000n;
}

export function calculateMaximumInput(amountIn: bigint, slippageBps: number): bigint {
  const factor = 10000n + BigInt(slippageBps);
  return (amountIn * factor) / 10000n;
}
