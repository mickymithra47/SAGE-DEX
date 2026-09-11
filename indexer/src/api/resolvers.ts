/**
 * @file resolvers.ts
 * @notice Query resolver functions for GraphQL & REST APIs.
 */

import { SageDatabase } from '../db/database.ts';
import type { PoolRecord, SwapRecord, CandleRecord, LPPositionRecord } from '../db/database.ts';
import { calculate24hVolumeAndFees } from '../engine/volumeAnalytics.ts';

export class SageResolvers {
  private db: SageDatabase;

  constructor(db: SageDatabase) {
    this.db = db;
  }

  public getPools(chainId: bigint): PoolRecord[] {
    return this.db.getPools(chainId);
  }

  public getPool(chainId: bigint, address: string): PoolRecord | undefined {
    return this.db.getPool(chainId, address);
  }

  public getSwaps(chainId: bigint, poolAddress?: string, limit: number = 50, cursor?: number): SwapRecord[] {
    return this.db.getSwaps(chainId, poolAddress, limit, cursor);
  }

  public getPoolSwaps(chainId: bigint, poolAddress: string, limit: number = 50, cursor?: number): SwapRecord[] {
    return this.db.getPoolSwaps(chainId, poolAddress, limit, cursor);
  }

  public getUserSwaps(chainId: bigint, userAddress: string, limit: number = 50): SwapRecord[] {
    return this.db.getUserSwaps(chainId, userAddress, limit);
  }

  public getUserPositions(chainId: bigint, userAddress: string): LPPositionRecord[] {
    return this.db.getUserPositions(chainId, userAddress);
  }

  public getCandles(
    chainId: bigint,
    poolAddress: string,
    interval: '1m' | '5m' | '1h' | '1d' = '1h',
    limit: number = 100
  ): CandleRecord[] {
    return this.db.getCandles(chainId, poolAddress, interval, limit);
  }

  public getPoolStats(chainId: bigint, poolAddress: string, currentTimestamp: bigint) {
    const pool = this.db.getPool(chainId, poolAddress);
    if (!pool) return null;

    const swaps = this.db.getPoolSwaps(chainId, poolAddress, 10000);
    const volume = calculate24hVolumeAndFees(swaps, currentTimestamp);

    return {
      poolAddress: pool.address,
      token0: pool.token0,
      token1: pool.token1,
      reserve0: pool.reserve0.toString(),
      reserve1: pool.reserve1.toString(),
      volume24hToken0: volume.volumeToken0.toString(),
      volume24hToken1: volume.volumeToken1.toString(),
      fees24hToken0: volume.feesToken0.toString(),
      fees24hToken1: volume.feesToken1.toString(),
      swapCount24h: volume.swapCount
    };
  }

  public getFreshness(chainId: bigint, currentChainBlock: bigint) {
    const latest = this.db.getLatestBlock(chainId);
    const latestIndexedBlock = latest ? latest.blockNumber : 0n;
    const lag = currentChainBlock > latestIndexedBlock ? currentChainBlock - latestIndexedBlock : 0n;
    const lagNumber = lag <= BigInt(Number.MAX_SAFE_INTEGER) ? Number(lag) : Number.MAX_SAFE_INTEGER;

    return {
      latestIndexedBlock: latestIndexedBlock.toString(),
      latestChainBlock: currentChainBlock.toString(),
      indexingLagBlocks: lagNumber,
      isHealthy: lag <= 5n
    };
  }
}
