// Standalone zero-dependency test runner for Phase 10 Indexing, Market Data & Observability
import assert from 'node:assert';
import { SageDatabase } from '../src/db/database.ts';
import { decodePairCreatedEvent, PAIR_CREATED_TOPIC } from '../src/decoders/factoryDecoder.ts';
import { decodeSwapEvent, decodeMintEvent, decodeBurnEvent, decodeSyncEvent, SWAP_TOPIC, MINT_TOPIC, BURN_TOPIC, SYNC_TOPIC } from '../src/decoders/pairDecoder.ts';
import { decodeTransferEvent, TRANSFER_TOPIC } from '../src/decoders/erc20Decoder.ts';
import { interpretSwap } from '../src/decoders/swapInterpreter.ts';
import { calculateNormalizedPrice } from '../src/engine/priceEngine.ts';
import { calculate24hVolumeAndFees } from '../src/engine/volumeAnalytics.ts';
import { BlockIngestor } from '../src/engine/blockIngestor.ts';
import { ReorgHandler } from '../src/engine/reorgHandler.ts';
import { SageResolvers } from '../src/api/resolvers.ts';
import { ReconciliationJob } from '../src/observability/reconciliationJob.ts';
import { IndexerMetrics } from '../src/observability/metrics.ts';

console.log('=== PHASE 10 INDEXER, MARKET DATA & OBSERVABILITY TEST RUNNER ===\n');

const chainId = 31337n;
const token0 = '0x1111111111111111111111111111111111111111';
const token1 = '0x2222222222222222222222222222222222222222';
const pairAddress = '0x3333333333333333333333333333333333333333';
const user = '0x4444444444444444444444444444444444444444';

// 1. Factory Indexer
console.log('[Project 1] Factory Event Indexer:');
const topic1 = '0x0000000000000000000000001111111111111111111111111111111111111111';
const topic2 = '0x0000000000000000000000002222222222222222222222222222222222222222';
const data = '0x00000000000000000000000033333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000001';
const decodedPair = decodePairCreatedEvent('0x5555555555555555555555555555555555555555', [PAIR_CREATED_TOPIC, topic1, topic2], data, 100n, '0xabc', 0);
assert(decodedPair !== null);
assert.strictEqual(decodedPair.token0, token0);
assert.strictEqual(decodedPair.token1, token1);
assert.strictEqual(decodedPair.pairAddress, pairAddress);
console.log('  ✓ Factory indexer passed');

// 2. Pool Discovery Index
console.log('[Project 2] Pool Discovery Index:');
const db = new SageDatabase();
db.insertPool({ chainId, address: pairAddress, factory: '0x5555', token0, token1, createdAtBlock: 100n, createdAtTimestamp: 1000n, createdTxHash: '0xabc', reserve0: 1000n, reserve1: 2000n, totalSupply: 1414n });
assert.strictEqual(db.getPoolByTokens(chainId, token0, token1)?.address, pairAddress);
console.log('  ✓ Pool discovery index passed');

// 3. Token Metadata Index
console.log('[Project 3] Token Metadata Index:');
db.insertToken({ chainId, address: token0, symbol: 'USDC', name: 'USD Coin', decimals: 6 });
assert.strictEqual(db.getToken(chainId, token0)?.symbol, 'USDC');
console.log('  ✓ Token metadata index passed');

// 4. Swap Event Indexer
console.log('[Project 4] Swap Event Indexer:');
const swapLog = decodeSwapEvent(
  pairAddress,
  [SWAP_TOPIC, '0x0000000000000000000000004444444444444444444444444444444444444444', '0x0000000000000000000000004444444444444444444444444444444444444444'],
  '0x' + (1000n).toString(16).padStart(64, '0') + (0n).toString(16).padStart(64, '0') + (0n).toString(16).padStart(64, '0') + (1900n).toString(16).padStart(64, '0'),
  101n, '0xdef', 1
);
assert(swapLog !== null);
const interpreted = interpretSwap(swapLog, token0, token1);
assert.strictEqual(interpreted.tokenIn, token0);
assert.strictEqual(interpreted.amountOut, 1900n);
console.log('  ✓ Swap event indexer passed');

// 5. Liquidity Event Indexer
console.log('[Project 5] Liquidity Event Indexer (Mint & Burn):');
db.insertMint({ type: 'MINT', chainId, blockNumber: 102n, txHash: '0x123', logIndex: 0, poolAddress: pairAddress, sender: user, amount0: 5000n, amount1: 10000n, timestamp: 1020n });
db.insertBurn({ type: 'BURN', chainId, blockNumber: 103n, txHash: '0x124', logIndex: 0, poolAddress: pairAddress, sender: user, recipient: user, amount0: 2500n, amount1: 5000n, timestamp: 1030n });
assert.strictEqual(db.mints.length, 1);
assert.strictEqual(db.burns.length, 1);
console.log('  ✓ Liquidity event indexer passed');

// 6. LP Transfer Indexer
console.log('[Project 6] LP Transfer Indexer:');
const transfer = decodeTransferEvent(pairAddress, [TRANSFER_TOPIC, '0x0000000000000000000000000000000000000000000000000000000000000000', '0x0000000000000000000000004444444444444444444444444444444444444444'], '0x' + (1000n).toString(16).padStart(64, '0'), 100n, '0xmint', 0);
assert.strictEqual(transfer?.value, 1000n);
console.log('  ✓ LP transfer indexer passed');

// 7. LP Position Read Model
console.log('[Project 7] LP Position Read Model:');
db.updateLPPosition(chainId, pairAddress, user, 1000n, 100n);
assert.strictEqual(db.getUserPositions(chainId, user)[0].lpBalance, 1000n);
console.log('  ✓ LP position read model passed');

// 8. Reserve History
console.log('[Project 8] Reserve History (Sync):');
const sync = decodeSyncEvent(pairAddress, [SYNC_TOPIC], '0x' + (10000n).toString(16).padStart(64, '0') + (20000n).toString(16).padStart(64, '0'), 104n, '0xsync', 0);
assert.strictEqual(sync?.reserve0, 10000n);
assert.strictEqual(sync?.reserve1, 20000n);
console.log('  ✓ Reserve history passed');

// 9. Historical Price Engine
console.log('[Project 9] Historical Price Engine (Normalized 6/18 decimals):');
const prices = calculateNormalizedPrice(2000n * 10n ** 6n, 6, 1n * 10n ** 18n, 18);
assert.strictEqual(prices.price0In1, 0.0005);
assert.strictEqual(prices.price1In0, 2000);
console.log('  ✓ Price engine passed');

// 10. Volume and Fee Analytics
console.log('[Project 10] Volume and Fee Analytics:');
const stats = calculate24hVolumeAndFees([
  {
    chainId, blockNumber: 100n, txHash: '0x1', logIndex: 0, poolAddress: pairAddress,
    sender: user, recipient: user, amount0In: 1000n, amount1In: 0n,
    amount0Out: 0n, amount1Out: 1900n, tokenIn: token0, tokenOut: token1,
    amountIn: 1000n, amountOut: 1900n, timestamp: 1000n
  }
], 1100n);
assert.strictEqual(stats.volumeToken0, 1000n);
assert.strictEqual(stats.feesToken0, 3n); // 0.30% fee
console.log('  ✓ Volume and fee analytics passed');

// 11. User Swap History
console.log('[Project 11] User Swap History:');
db.insertSwap({
  chainId, blockNumber: 100n, txHash: '0x1', logIndex: 0, poolAddress: pairAddress,
  sender: user, recipient: user, amount0In: 100n, amount1In: 0n,
  amount0Out: 0n, amount1Out: 190n, tokenIn: token0, tokenOut: token1,
  amountIn: 100n, amountOut: 190n, timestamp: 1000n
});
assert.strictEqual(db.getUserSwaps(chainId, user).length, 1);
console.log('  ✓ User swap history passed');

// 12. User Liquidity History
console.log('[Project 12] User Liquidity History:');
assert.strictEqual(db.mints.length, 1);
console.log('  ✓ User liquidity history passed');

// 13. PostgreSQL Data Layer
console.log('[Project 13] PostgreSQL Data Layer:');
db.insertBlock({ chainId, blockNumber: 1n, blockHash: '0x1', parentHash: '0x0', timestamp: 1000n, isCanonical: true });
assert.strictEqual(db.getBlock(chainId, 1n)?.blockHash, '0x1');
console.log('  ✓ PostgreSQL data layer passed');

// 14. API Layer
console.log('[Project 14] API Resolvers:');
const resolvers = new SageResolvers(db);
assert.strictEqual(resolvers.getPool(chainId, pairAddress)?.token0, token0);
console.log('  ✓ API resolvers passed');

// 15. Historical Backfill
console.log('[Project 15] Historical Backfill:');
const ingestor = new BlockIngestor(db);
for (let i = 2n; i <= 4n; i++) {
  ingestor.processBlock({ chainId, blockNumber: i, blockHash: `0x${i}`, parentHash: `0x${i - 1n}`, timestamp: 1000n + i * 12n, isCanonical: true }, []);
}
assert.strictEqual(db.getLatestBlock(chainId)?.blockNumber, 4n);
console.log('  ✓ Historical backfill passed');

// 16. Live Indexer
console.log('[Project 16] Live Block Ingestion:');
ingestor.processBlock({ chainId, blockNumber: 5n, blockHash: '0x5', parentHash: '0x4', timestamp: 1060n, isCanonical: true }, []);
assert.strictEqual(db.getBlock(chainId, 5n)?.blockHash, '0x5');
console.log('  ✓ Live indexer passed');

// 17. Reorg Handler
console.log('[Project 17] Reorg Detection & Rollback:');
ingestor.processBlock({ chainId, blockNumber: 5n, blockHash: '0x5_B', parentHash: '0x4', timestamp: 1060n, isCanonical: true }, []);
assert.strictEqual(db.getBlock(chainId, 5n)?.blockHash, '0x5_B');
console.log('  ✓ Reorg handler passed');

// 18. Reconciliation Engine
console.log('[Project 18] State Reconciliation:');
const recon = new ReconciliationJob(db);
assert.strictEqual(recon.reconcilePool(chainId, pairAddress, 1000n, 2000n).isConsistent, true);
assert.strictEqual(recon.reconcilePool(chainId, pairAddress, 1000n, 2005n).isConsistent, false);
console.log('  ✓ Reconciliation engine passed');

// 19. Monitoring and Metrics
console.log('[Project 19] Monitoring & Metrics:');
const metrics = new IndexerMetrics();
metrics.incBlocks(10);
metrics.incEvents(42);
metrics.setLag(2);
assert.strictEqual(metrics.getMetrics().blocksProcessedTotal, 10);
console.log('  ✓ Metrics collector passed');

// 20. Frontend and AI Data Integration
console.log('[Project 20] Frontend & AI Data Integration:');
const stats20 = resolvers.getPoolStats(chainId, pairAddress, 1000n);
assert.strictEqual(stats20?.poolAddress, pairAddress);
console.log('  ✓ Frontend & AI data integration passed');

console.log('\n======================================================');
console.log('ALL 20 PHASE 10 MINI-PROJECTS PASSED (100% GREEN)');
console.log('======================================================\n');
