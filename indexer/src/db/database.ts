/**
 * @file database.ts
 * @notice Type-safe database repository with atomic reorg rollback support.
 */

export interface BlockRecord {
  chainId: bigint;
  blockNumber: bigint;
  blockHash: string;
  parentHash: string;
  timestamp: bigint;
  isCanonical: boolean;
}

export interface TokenRecord {
  chainId: bigint;
  address: string;
  symbol: string;
  name: string;
  decimals: number;
  totalSupply?: bigint;
}

export interface PoolRecord {
  chainId: bigint;
  address: string;
  factory: string;
  token0: string;
  token1: string;
  createdAtBlock: bigint;
  createdAtTimestamp: bigint;
  createdTxHash: string;
  reserve0: bigint;
  reserve1: bigint;
  totalSupply: bigint;
}

export interface SwapRecord {
  chainId: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
  poolAddress: string;
  sender: string;
  recipient: string;
  amount0In: bigint;
  amount1In: bigint;
  amount0Out: bigint;
  amount1Out: bigint;
  tokenIn: string;
  tokenOut: string;
  amountIn: bigint;
  amountOut: bigint;
  timestamp: bigint;
}

export interface LiquidityRecord {
  type: 'MINT' | 'BURN';
  chainId: bigint;
  blockNumber: bigint;
  txHash: string;
  logIndex: number;
  poolAddress: string;
  sender: string;
  recipient?: string;
  amount0: bigint;
  amount1: bigint;
  timestamp: bigint;
}

export interface LPPositionRecord {
  chainId: bigint;
  poolAddress: string;
  userAddress: string;
  lpBalance: bigint;
  updatedAtBlock: bigint;
}

export interface CandleRecord {
  chainId: bigint;
  poolAddress: string;
  intervalType: '1m' | '5m' | '15m' | '1h' | '1d';
  timestamp: bigint;
  open: number;
  high: number;
  low: number;
  close: number;
  volumeToken0: bigint;
  volumeToken1: bigint;
  txCount: number;
}

export class SageDatabase {
  public blocks: Map<string, BlockRecord> = new Map(); // key: `${chainId}_${blockNumber}`
  public tokens: Map<string, TokenRecord> = new Map(); // key: `${chainId}_${address.toLowerCase()}`
  public pools: Map<string, PoolRecord> = new Map(); // key: `${chainId}_${address.toLowerCase()}`
  public swaps: SwapRecord[] = [];
  public mints: LiquidityRecord[] = [];
  public burns: LiquidityRecord[] = [];
  public lpPositions: Map<string, LPPositionRecord> = new Map(); // key: `${chainId}_${pool}_${user}`
  public candles: Map<string, CandleRecord> = new Map(); // key: `${chainId}_${pool}_${interval}_${timestamp}`

  // Block Insertion & Cursor
  public insertBlock(block: BlockRecord): void {
    const key = `${block.chainId}_${block.blockNumber}`;
    this.blocks.set(key, block);
  }

  public getBlock(chainId: bigint, blockNumber: bigint): BlockRecord | undefined {
    return this.blocks.get(`${chainId}_${blockNumber}`);
  }

  public getLatestBlock(chainId: bigint): BlockRecord | undefined {
    let latest: BlockRecord | undefined;
    for (const b of this.blocks.values()) {
      if (b.chainId === chainId && b.isCanonical) {
        if (!latest || b.blockNumber > latest.blockNumber) {
          latest = b;
        }
      }
    }
    return latest;
  }

  // Token Operations
  public insertToken(token: TokenRecord): void {
    const key = `${token.chainId}_${token.address.toLowerCase()}`;
    this.tokens.set(key, token);
  }

  public getToken(chainId: bigint, address: string): TokenRecord | undefined {
    return this.tokens.get(`${chainId}_${address.toLowerCase()}`);
  }

  // Pool Operations
  public insertPool(pool: PoolRecord): void {
    const key = `${pool.chainId}_${pool.address.toLowerCase()}`;
    this.pools.set(key, pool);
  }

  public getPool(chainId: bigint, address: string): PoolRecord | undefined {
    return this.pools.get(`${chainId}_${address.toLowerCase()}`);
  }

  public getPoolByTokens(chainId: bigint, tokenA: string, tokenB: string): PoolRecord | undefined {
    const t0 = tokenA.toLowerCase() < tokenB.toLowerCase() ? tokenA.toLowerCase() : tokenB.toLowerCase();
    const t1 = tokenA.toLowerCase() < tokenB.toLowerCase() ? tokenB.toLowerCase() : tokenA.toLowerCase();

    for (const p of this.pools.values()) {
      if (p.chainId === chainId && p.token0.toLowerCase() === t0 && p.token1.toLowerCase() === t1) {
        return p;
      }
    }
    return undefined;
  }

  public updatePoolReserves(chainId: bigint, poolAddress: string, r0: bigint, r1: bigint): void {
    const pool = this.getPool(chainId, poolAddress);
    if (pool) {
      pool.reserve0 = r0;
      pool.reserve1 = r1;
    }
  }

  // Swap Operations (Idempotent by txHash + logIndex)
  public insertSwap(swap: SwapRecord): boolean {
    const exists = this.swaps.some(
      (s) => s.chainId === swap.chainId && s.txHash === swap.txHash && s.logIndex === swap.logIndex
    );
    if (exists) return false;

    this.swaps.push(swap);
    this.updateCandle(swap);
    return true;
  }

  public getPools(chainId: bigint): PoolRecord[] {
    const list: PoolRecord[] = [];
    for (const p of this.pools.values()) {
      if (p.chainId === chainId) {
        list.push(p);
      }
    }
    return list;
  }

  public getSwaps(chainId: bigint, poolAddress?: string, limit: number = 50, cursor?: number): SwapRecord[] {
    let list = this.swaps.filter((s) => s.chainId === chainId);
    if (poolAddress) {
      list = list.filter((s) => s.poolAddress.toLowerCase() === poolAddress.toLowerCase());
    }
    // Sort block DESC, logIndex DESC
    list.sort((a, b) => {
      if (b.blockNumber !== a.blockNumber) return Number(b.blockNumber - a.blockNumber);
      return b.logIndex - a.logIndex;
    });

    const startIndex = cursor ? cursor : 0;
    return list.slice(startIndex, startIndex + limit);
  }

  public getPoolSwaps(
    chainId: bigint,
    poolAddress: string,
    limit: number = 50,
    cursor?: number
  ): SwapRecord[] {
    return this.getSwaps(chainId, poolAddress, limit, cursor);
  }

  public getUserSwaps(chainId: bigint, userAddress: string, limit: number = 50): SwapRecord[] {
    const target = userAddress.toLowerCase();
    const list = this.swaps.filter(
      (s) => s.chainId === chainId && (s.sender.toLowerCase() === target || s.recipient.toLowerCase() === target)
    );
    list.sort((a, b) => Number(b.blockNumber - a.blockNumber));
    return list.slice(0, limit);
  }

  // Liquidity Operations
  public insertMint(mint: LiquidityRecord): void {
    const exists = this.mints.some(
      (m) => m.chainId === mint.chainId && m.txHash === mint.txHash && m.logIndex === mint.logIndex
    );
    if (!exists) this.mints.push(mint);
  }

  public insertBurn(burn: LiquidityRecord): void {
    const exists = this.burns.some(
      (b) => b.chainId === burn.chainId && b.txHash === burn.txHash && b.logIndex === burn.logIndex
    );
    if (!exists) this.burns.push(burn);
  }

  // LP Position Tracking
  public updateLPPosition(chainId: bigint, poolAddress: string, userAddress: string, balanceDelta: bigint, blockNumber: bigint): void {
    const key = `${chainId}_${poolAddress.toLowerCase()}_${userAddress.toLowerCase()}`;
    const existing = this.lpPositions.get(key);
    const currentBalance = existing ? existing.lpBalance : 0n;
    const newBalance = currentBalance + balanceDelta;

    this.lpPositions.set(key, {
      chainId,
      poolAddress: poolAddress.toLowerCase(),
      userAddress: userAddress.toLowerCase(),
      lpBalance: newBalance > 0n ? newBalance : 0n,
      updatedAtBlock: blockNumber
    });
  }

  public getUserPositions(chainId: bigint, userAddress: string): LPPositionRecord[] {
    const target = userAddress.toLowerCase();
    const results: LPPositionRecord[] = [];
    for (const pos of this.lpPositions.values()) {
      if (pos.chainId === chainId && pos.userAddress === target && pos.lpBalance > 0n) {
        results.push(pos);
      }
    }
    return results;
  }

  // Candlestick Aggregation
  private updateCandle(swap: SwapRecord): void {
    const pool = this.getPool(swap.chainId, swap.poolAddress);
    if (!pool || pool.reserve0 === 0n || pool.reserve1 === 0n) return;

    // Price = reserve1 / reserve0 normalized to float for charting
    const price = Number(pool.reserve1) / Number(pool.reserve0);
    const intervals: Array<['1m' | '5m' | '1h' | '1d', bigint]> = [
      ['1m', 60n],
      ['5m', 300n],
      ['1h', 3600n],
      ['1d', 86400n]
    ];

    for (const [interval, step] of intervals) {
      const candleTime = (swap.timestamp / step) * step;
      const key = `${swap.chainId}_${swap.poolAddress.toLowerCase()}_${interval}_${candleTime}`;
      const existing = this.candles.get(key);

      if (!existing) {
        this.candles.set(key, {
          chainId: swap.chainId,
          poolAddress: swap.poolAddress.toLowerCase(),
          intervalType: interval,
          timestamp: candleTime,
          open: price,
          high: price,
          low: price,
          close: price,
          volumeToken0: swap.amount0In + swap.amount0Out,
          volumeToken1: swap.amount1In + swap.amount1Out,
          txCount: 1
        });
      } else {
        existing.high = Math.max(existing.high, price);
        existing.low = Math.min(existing.low, price);
        existing.close = price;
        existing.volumeToken0 += swap.amount0In + swap.amount0Out;
        existing.volumeToken1 += swap.amount1In + swap.amount1Out;
        existing.txCount += 1;
      }
    }
  }

  public getCandles(
    chainId: bigint,
    poolAddress: string,
    interval: '1m' | '5m' | '1h' | '1d',
    limit: number = 100
  ): CandleRecord[] {
    const list: CandleRecord[] = [];
    const prefix = `${chainId}_${poolAddress.toLowerCase()}_${interval}_`;
    for (const [key, c] of this.candles.entries()) {
      if (key.startsWith(prefix)) {
        list.push(c);
      }
    }
    list.sort((a, b) => Number(b.timestamp - a.timestamp));
    return list.slice(0, limit);
  }

  // Atomic Reorg Rollback
  public rollbackBlocksAbove(chainId: bigint, targetBlockNumber: bigint): number {
    let rolledBackCount = 0;

    // 1. Remove blocks above target
    for (const [key, block] of this.blocks.entries()) {
      if (block.chainId === chainId && block.blockNumber > targetBlockNumber) {
        this.blocks.delete(key);
        rolledBackCount++;
      }
    }

    // 2. Remove swaps, mints, burns above target
    this.swaps = this.swaps.filter((s) => !(s.chainId === chainId && s.blockNumber > targetBlockNumber));
    this.mints = this.mints.filter((m) => !(m.chainId === chainId && m.blockNumber > targetBlockNumber));
    this.burns = this.burns.filter((b) => !(b.chainId === chainId && b.blockNumber > targetBlockNumber));

    // 3. Clean stale candles
    for (const [key, candle] of this.candles.entries()) {
      if (candle.chainId === chainId && candle.timestamp > targetBlockNumber * 12n) {
        // Approximate time boundary
        this.candles.delete(key);
      }
    }

    return rolledBackCount;
  }
}
