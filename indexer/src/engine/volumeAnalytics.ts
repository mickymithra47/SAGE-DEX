/**
 * @file volumeAnalytics.ts
 * @notice Calculates rolling 24h trading volume and 0.30% swap fee accumulation.
 */

import type { SwapRecord } from '../db/database.ts';

export interface PoolVolumeStats {
  volumeToken0: bigint;
  volumeToken1: bigint;
  feesToken0: bigint;
  feesToken1: bigint;
  swapCount: number;
}

export function calculate24hVolumeAndFees(
  swaps: SwapRecord[],
  currentTimestamp: bigint
): PoolVolumeStats {
  const windowStart = currentTimestamp > 86400n ? currentTimestamp - 86400n : 0n;
  const recentSwaps = swaps.filter((s) => s.timestamp >= windowStart);

  let volumeToken0 = 0n;
  let volumeToken1 = 0n;
  let feesToken0 = 0n;
  let feesToken1 = 0n;

  for (const s of recentSwaps) {
    const in0 = s.amount0In;
    const in1 = s.amount1In;

    volumeToken0 += in0 + s.amount0Out;
    volumeToken1 += in1 + s.amount1Out;

    // 0.30% (30 / 10000 = 3 / 1000)
    feesToken0 += (in0 * 3n) / 1000n;
    feesToken1 += (in1 * 3n) / 1000n;
  }

  return {
    volumeToken0,
    volumeToken1,
    feesToken0,
    feesToken1,
    swapCount: recentSwaps.length
  };
}
