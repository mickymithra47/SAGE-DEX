// Regression and validation test suite for SageResolvers and SageDatabase
import assert from 'node:assert';
import { SageDatabase } from '../src/db/database.ts';
import { SageResolvers } from '../src/api/resolvers.ts';

console.log('=== SAGE RESOLVERS & DATABASE REGRESSION TEST SUITE ===\n');

const db = new SageDatabase();
const resolvers = new SageResolvers(db);

const chainId = 11155111n;
const poolAddress = '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6';
const token0 = '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707';
const token1 = '0x0165878A594ca255338adfa4d48449f69242Eb8F';
const user = '0x1111111111111111111111111111111111111111';

// 1. Insert Block & Pool
db.insertBlock({
  chainId,
  blockNumber: 100n,
  blockHash: '0xabc100',
  parentHash: '0xabc99',
  timestamp: 1000n,
  isCanonical: true
});

db.insertPool({
  chainId,
  address: poolAddress,
  factory: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  token0,
  token1,
  createdAtBlock: 100n,
  createdAtTimestamp: 1000n,
  createdTxHash: '0xtx1',
  reserve0: 100000n * 10n ** 18n,
  reserve1: 100000n * 10n ** 6n,
  totalSupply: 100000n * 10n ** 18n
});

// 2. Test getPools() & getPool() with case-insensitivity
console.log('Test 1: getPools and getPool');
const pools = resolvers.getPools(chainId);
assert.strictEqual(pools.length, 1);
assert.strictEqual(pools[0].address, poolAddress);

const poolUpper = resolvers.getPool(chainId, poolAddress.toUpperCase());
assert(poolUpper !== undefined);
assert.strictEqual(poolUpper.address, poolAddress);
console.log('  ✓ getPools and getPool passed');

// 3. Insert Swaps and test getSwaps() & getPoolSwaps()
console.log('Test 2: getSwaps and getPoolSwaps');
db.insertSwap({
  chainId,
  blockNumber: 101n,
  txHash: '0xswap1',
  logIndex: 0,
  poolAddress,
  sender: user,
  recipient: user,
  amount0In: 1000n * 10n ** 18n,
  amount1In: 0n,
  amount0Out: 0n,
  amount1Out: 987n * 10n ** 6n,
  tokenIn: token0,
  tokenOut: token1,
  amountIn: 1000n * 10n ** 18n,
  amountOut: 987n * 10n ** 6n,
  timestamp: 1010n
});

const allSwaps = resolvers.getSwaps(chainId);
assert.strictEqual(allSwaps.length, 1);

const poolSwaps = resolvers.getPoolSwaps(chainId, poolAddress.toLowerCase());
assert.strictEqual(poolSwaps.length, 1);
assert.strictEqual(poolSwaps[0].txHash, '0xswap1');
console.log('  ✓ getSwaps and getPoolSwaps passed');

// 4. Test getUserSwaps()
console.log('Test 3: getUserSwaps');
const userSwaps = resolvers.getUserSwaps(chainId, user);
assert.strictEqual(userSwaps.length, 1);
assert.strictEqual(userSwaps[0].sender, user);
console.log('  ✓ getUserSwaps passed');

// 5. Test getUserPositions()
console.log('Test 4: getUserPositions');
db.updateLPPosition(chainId, poolAddress, user, 5000n, 100n);
const userPositions = resolvers.getUserPositions(chainId, user);
assert.strictEqual(userPositions.length, 1);
assert.strictEqual(userPositions[0].lpBalance, 5000n);
console.log('  ✓ getUserPositions passed');

// 6. Test getCandles()
console.log('Test 5: getCandles');
const candles = resolvers.getCandles(chainId, poolAddress, '1h');
assert(candles.length > 0);
console.log('  ✓ getCandles passed');

// 7. Test getPoolStats()
console.log('Test 6: getPoolStats');
const stats = resolvers.getPoolStats(chainId, poolAddress, 1020n);
assert(stats !== null);
assert.strictEqual(stats.poolAddress, poolAddress);
assert.strictEqual(stats.swapCount24h, 1);
assert.strictEqual(stats.volume24hToken0, (1000n * 10n ** 18n).toString());
console.log('  ✓ getPoolStats passed');

// 8. Test getFreshness() with normal and large lag bounds
console.log('Test 7: getFreshness');
const freshnessNormal = resolvers.getFreshness(chainId, 103n);
assert.strictEqual(freshnessNormal.latestIndexedBlock, '100');
assert.strictEqual(freshnessNormal.latestChainBlock, '103');
assert.strictEqual(freshnessNormal.indexingLagBlocks, 3);
assert.strictEqual(freshnessNormal.isHealthy, true);

const freshnessLarge = resolvers.getFreshness(chainId, 1000000000000n);
assert.strictEqual(typeof freshnessLarge.indexingLagBlocks, 'number');
assert.strictEqual(freshnessLarge.isHealthy, false);
console.log('  ✓ getFreshness passed');

console.log('\n======================================================');
console.log('ALL RESOLVER REGRESSION TESTS PASSED (100% GREEN)');
console.log('======================================================\n');
