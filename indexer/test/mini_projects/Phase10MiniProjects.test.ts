import { describe, it } from 'node:test';
import assert from 'node:assert';
import { SageDatabase } from '../../src/db/database.ts';
import { decodePairCreatedEvent, PAIR_CREATED_TOPIC } from '../../src/decoders/factoryDecoder.ts';
import { decodeSwapEvent, decodeMintEvent, decodeBurnEvent, decodeSyncEvent, SWAP_TOPIC, MINT_TOPIC, BURN_TOPIC, SYNC_TOPIC } from '../../src/decoders/pairDecoder.ts';
import { decodeTransferEvent, TRANSFER_TOPIC } from '../../src/decoders/erc20Decoder.ts';
import { interpretSwap } from '../../src/decoders/swapInterpreter.ts';
import { calculateNormalizedPrice } from '../../src/engine/priceEngine.ts';
import { calculate24hVolumeAndFees } from '../../src/engine/volumeAnalytics.ts';
import { BlockIngestor } from '../../src/engine/blockIngestor.ts';
import { ReorgHandler } from '../../src/engine/reorgHandler.ts';
import { SageResolvers } from '../../src/api/resolvers.ts';
import { ReconciliationJob } from '../../src/observability/reconciliationJob.ts';
import { IndexerMetrics } from '../../src/observability/metrics.ts';

function expect<T>(actual: T) {
  return {
    toBe(expected: any) {
      assert.strictEqual(actual, expected);
    },
    toEqual(expected: any) {
      assert.deepStrictEqual(actual, expected);
    },
    toBeDefined() {
      assert.notStrictEqual(actual, undefined);
    },
    toBeNull() {
      assert.strictEqual(actual, null);
    },
    toBeTruthy() {
      assert.ok(actual);
    },
    toBeFalsy() {
      assert.ok(!actual);
    }
  };
}

describe('Phase 10 — 20 Mini-Projects Suite', () => {
  const chainId = 31337n;
  const token0 = '0x1111111111111111111111111111111111111111';
  const token1 = '0x2222222222222222222222222222222222222222';
  const pairAddress = '0x3333333333333333333333333333333333333333';
  const user = '0x4444444444444444444444444444444444444444';

  it('Project 1: Factory Indexer', () => {
    const topic1 = '0x0000000000000000000000001111111111111111111111111111111111111111';
    const topic2 = '0x0000000000000000000000002222222222222222222222222222222222222222';
    const data = '0x00000000000000000000000033333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000001';

    const decoded = decodePairCreatedEvent('0x5555555555555555555555555555555555555555', [PAIR_CREATED_TOPIC, topic1, topic2], data, 100n, '0xabc', 0);
    expect(decoded?.token0).toBe(token0);
    expect(decoded?.token1).toBe(token1);
    expect(decoded?.pairAddress).toBe(pairAddress);
  });

  it('Project 2: Pool Discovery Index', () => {
    const db = new SageDatabase();
    db.insertPool({
      chainId, address: pairAddress, factory: '0x5555', token0, token1,
      createdAtBlock: 100n, createdAtTimestamp: 1000n, createdTxHash: '0xabc',
      reserve0: 1000n, reserve1: 2000n, totalSupply: 1414n
    });

    const pool = db.getPoolByTokens(chainId, token0, token1);
    expect(pool?.address).toBe(pairAddress);
  });

  it('Project 3: Token Metadata Index', () => {
    const db = new SageDatabase();
    db.insertToken({ chainId, address: token0, symbol: 'USDC', name: 'USD Coin', decimals: 6 });
    expect(db.getToken(chainId, token0)?.symbol).toBe('USDC');
  });

  it('Project 4: Swap Event Indexer', () => {
    const decoded = decodeSwapEvent(
      pairAddress,
      [SWAP_TOPIC, '0x0000000000000000000000004444444444444444444444444444444444444444', '0x0000000000000000000000004444444444444444444444444444444444444444'],
      '0x' + (1000n).toString(16).padStart(64, '0') + (0n).toString(16).padStart(64, '0') + (0n).toString(16).padStart(64, '0') + (1900n).toString(16).padStart(64, '0'),
      101n, '0xdef', 1
    );
    const interpreted = interpretSwap(decoded!, token0, token1);
    expect(interpreted.tokenIn).toBe(token0);
    expect(interpreted.amountOut).toBe(1900n);
  });

  it('Project 5: Liquidity Event Indexer', () => {
    const db = new SageDatabase();
    db.insertMint({ type: 'MINT', chainId, blockNumber: 102n, txHash: '0x123', logIndex: 0, poolAddress: pairAddress, sender: user, amount0: 5000n, amount1: 10000n, timestamp: 1020n });
    db.insertBurn({ type: 'BURN', chainId, blockNumber: 103n, txHash: '0x124', logIndex: 0, poolAddress: pairAddress, sender: user, recipient: user, amount0: 2500n, amount1: 5000n, timestamp: 1030n });
    expect(db.mints.length).toBe(1);
    expect(db.burns.length).toBe(1);
  });

  it('Project 6: LP Transfer Indexer', () => {
    const transfer = decodeTransferEvent(
      pairAddress,
      [TRANSFER_TOPIC, '0x0000000000000000000000000000000000000000000000000000000000000000', '0x0000000000000000000000004444444444444444444444444444444444444444'],
      '0x' + (1000n).toString(16).padStart(64, '0'),
      100n, '0xmint', 0
    );
    expect(transfer?.value).toBe(1000n);
  });

  it('Project 7: LP Position Read Model', () => {
    const db = new SageDatabase();
    db.updateLPPosition(chainId, pairAddress, user, 1000n, 100n);
    const positions = db.getUserPositions(chainId, user);
    expect(positions[0].lpBalance).toBe(1000n);
  });

  it('Project 8: Reserve History', () => {
    const sync = decodeSyncEvent(pairAddress, [SYNC_TOPIC], '0x' + (10000n).toString(16).padStart(64, '0') + (20000n).toString(16).padStart(64, '0'), 104n, '0xsync', 0);
    expect(sync?.reserve0).toBe(10000n);
    expect(sync?.reserve1).toBe(20000n);
  });

  it('Project 9: Historical Price Engine', () => {
    const prices = calculateNormalizedPrice(2000n * 10n ** 6n, 6, 1n * 10n ** 18n, 18);
    expect(prices.price0In1).toBe(0.0005);
    expect(prices.price1In0).toBe(2000);
  });

  it('Project 10: Volume and Fee Analytics', () => {
    const stats = calculate24hVolumeAndFees([
      {
        chainId, blockNumber: 100n, txHash: '0x1', logIndex: 0, poolAddress: pairAddress,
        sender: user, recipient: user, amount0In: 1000n, amount1In: 0n,
        amount0Out: 0n, amount1Out: 1900n, tokenIn: token0, tokenOut: token1,
        amountIn: 1000n, amountOut: 1900n, timestamp: 1000n
      }
    ], 1100n);
    expect(stats.volumeToken0).toBe(1000n);
    expect(stats.feesToken0).toBe(3n);
  });

  it('Project 11: User Swap History', () => {
    const db = new SageDatabase();
    db.insertSwap({
      chainId, blockNumber: 100n, txHash: '0x1', logIndex: 0, poolAddress: pairAddress,
      sender: user, recipient: user, amount0In: 100n, amount1In: 0n,
      amount0Out: 0n, amount1Out: 190n, tokenIn: token0, tokenOut: token1,
      amountIn: 100n, amountOut: 190n, timestamp: 1000n
    });
    const history = db.getUserSwaps(chainId, user);
    expect(history.length).toBe(1);
  });

  it('Project 12: User Liquidity History', () => {
    const db = new SageDatabase();
    db.insertMint({ type: 'MINT', chainId, blockNumber: 100n, txHash: '0x1', logIndex: 0, poolAddress: pairAddress, sender: user, amount0: 500n, amount1: 1000n, timestamp: 1000n });
    expect(db.mints.length).toBe(1);
  });

  it('Project 13: PostgreSQL Data Layer', () => {
    const db = new SageDatabase();
    db.insertBlock({ chainId, blockNumber: 1n, blockHash: '0x1', parentHash: '0x0', timestamp: 1000n, isCanonical: true });
    expect(db.getBlock(chainId, 1n)?.blockHash).toBe('0x1');
  });

  it('Project 14: API Layer', () => {
    const db = new SageDatabase();
    db.insertPool({ chainId, address: pairAddress, factory: '0x5555', token0, token1, createdAtBlock: 100n, createdAtTimestamp: 1000n, createdTxHash: '0xabc', reserve0: 1000n, reserve1: 2000n, totalSupply: 1414n });
    const resolvers = new SageResolvers(db);
    expect(resolvers.getPool(chainId, pairAddress)?.token0).toBe(token0);
  });

  it('Project 15: Historical Backfill', () => {
    const db = new SageDatabase();
    const ingestor = new BlockIngestor(db);
    for (let i = 1n; i <= 3n; i++) {
      ingestor.processBlock({ chainId, blockNumber: i, blockHash: `0x${i}`, parentHash: `0x${i - 1n}`, timestamp: 1000n + i * 12n, isCanonical: true }, []);
    }
    expect(db.getLatestBlock(chainId)?.blockNumber).toBe(3n);
  });

  it('Project 16: Live Indexer', () => {
    const db = new SageDatabase();
    const ingestor = new BlockIngestor(db);
    ingestor.processBlock({ chainId, blockNumber: 4n, blockHash: '0x4', parentHash: '0x3', timestamp: 1048n, isCanonical: true }, []);
    expect(db.getBlock(chainId, 4n)?.blockHash).toBe('0x4');
  });

  it('Project 17: Reorg Handler', () => {
    const db = new SageDatabase();
    const ingestor = new BlockIngestor(db);
    ingestor.processBlock({ chainId, blockNumber: 1n, blockHash: '0x1_A', parentHash: '0x0', timestamp: 1000n, isCanonical: true }, []);
    ingestor.processBlock({ chainId, blockNumber: 2n, blockHash: '0x2_A', parentHash: '0x1_A', timestamp: 1012n, isCanonical: true }, []);
    ingestor.processBlock({ chainId, blockNumber: 2n, blockHash: '0x2_B', parentHash: '0x1_A', timestamp: 1012n, isCanonical: true }, []);
    expect(db.getBlock(chainId, 2n)?.blockHash).toBe('0x2_B');
  });

  it('Project 18: Reconciliation Engine', () => {
    const db = new SageDatabase();
    db.insertPool({ chainId, address: pairAddress, factory: '0x5555', token0, token1, createdAtBlock: 100n, createdAtTimestamp: 1000n, createdTxHash: '0xabc', reserve0: 1000n, reserve1: 2000n, totalSupply: 1414n });
    const recon = new ReconciliationJob(db);
    expect(recon.reconcilePool(chainId, pairAddress, 1000n, 2000n).isConsistent).toBe(true);
    expect(recon.reconcilePool(chainId, pairAddress, 1000n, 2005n).isConsistent).toBe(false);
  });

  it('Project 19: Monitoring and Metrics', () => {
    const metrics = new IndexerMetrics();
    metrics.incBlocks(5);
    metrics.incEvents(12);
    metrics.setLag(1);
    const data = metrics.getMetrics();
    expect(data.blocksProcessedTotal).toBe(5);
    expect(data.eventsProcessedTotal).toBe(12);
    expect(data.indexerLagBlocks).toBe(1);
  });

  it('Project 20: Frontend and AI Data Integration', () => {
    const db = new SageDatabase();
    db.insertPool({ chainId, address: pairAddress, factory: '0x5555', token0, token1, createdAtBlock: 100n, createdAtTimestamp: 1000n, createdTxHash: '0xabc', reserve0: 1000n, reserve1: 2000n, totalSupply: 1414n });
    const resolvers = new SageResolvers(db);
    const stats = resolvers.getPoolStats(chainId, pairAddress, 1000n);
    expect(stats?.poolAddress).toBe(pairAddress);
    expect(stats?.reserve0).toBe('1000');
  });
});
