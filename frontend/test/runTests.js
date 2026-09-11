// Standalone zero-dependency test runner for Phase 8 Frontend Math, Error Decoder, and Mini-Projects
import assert from 'node:assert';
import {
  parseUnits,
  formatUnits,
  getAmountOut,
  getAmountIn,
  calculatePriceImpactBps,
  calculateMinimumOutput,
  calculateMaximumInput
} from '../src/lib/math.ts';
import { decodeContractError } from '../src/lib/errorDecoder.ts';
import { getContractsForChain } from '../src/config/contracts.ts';
import { DEFAULT_TOKENS } from '../src/config/tokens.ts';
import { buildSwapExactTokensCalldata } from '../src/lib/txBuilder.ts';

console.log('=== PHASE 8 FRONTEND TEST SUITE RUNNER ===\n');

// 1. Math Tests
console.log('[Test 1] BigInt Decimal Parsing:');
assert.strictEqual(parseUnits('1.5', 6), 1500000n);
assert.strictEqual(parseUnits('1.5', 18), 1500000000000000000n);
assert.strictEqual(parseUnits('0.000001', 6), 1n);
console.log('  ✓ BigInt parseUnits passed');

console.log('[Test 2] BigInt Decimal Formatting:');
assert.strictEqual(formatUnits(1500000n, 6), '1.5');
assert.strictEqual(formatUnits(1500000000000000000n, 18), '1.5');
assert.strictEqual(formatUnits(1n, 6), '0.000001');
console.log('  ✓ BigInt formatUnits passed');

console.log('[Test 3] Constant-Product Quote Math (Exact Input):');
const out = getAmountOut(10n * 10n ** 18n, 1000n * 10n ** 18n, 2000n * 10n ** 18n);
assert.strictEqual(out, 19743160687941225977n);
console.log('  ✓ Exact-input quote passed (out = 19.743160...)');

console.log('[Test 4] Constant-Product Quote Math (Exact Output):');
const requiredIn = getAmountIn(out, 1000n * 10n ** 18n, 2000n * 10n ** 18n);
assert.strictEqual(requiredIn, 10000000000000000000n);
console.log('  ✓ Exact-output quote passed (in = 10.000000...)');

console.log('[Test 5] Slippage Bounds Calculation:');
assert.strictEqual(calculateMinimumOutput(10000n, 50), 9950n);
assert.strictEqual(calculateMaximumInput(10000n, 50), 10050n);
console.log('  ✓ Slippage bounds passed');

console.log('[Test 6] Price Impact Calculation:');
const impact = calculatePriceImpactBps(10n * 10n ** 18n, out, 1000n * 10n ** 18n, 2000n * 10n ** 18n);
assert(impact >= 120, 'Price impact should be ~1.28%');
console.log('  ✓ Price impact calculation passed (' + (impact / 100).toFixed(2) + '%)');

// 2. Error Decoder Tests
console.log('[Test 7] Custom Error Decoding:');
assert.strictEqual(decodeContractError({ message: 'Expired()' }).title, 'Transaction Expired');
assert.strictEqual(decodeContractError({ message: 'InsufficientOutput()' }).title, 'Slippage Tolerance Breached');
assert.strictEqual(decodeContractError({ message: 'PairNotFound()' }).title, 'Pool Does Not Exist');
assert.strictEqual(decodeContractError({ message: 'User rejected' }).title, 'Signature Rejected');
console.log('  ✓ Custom error decoding passed');

// 3. Contract Registry & Token Config Tests
console.log('[Test 8] Typed Contract Registry & Tokens:');
const contracts = getContractsForChain(31337);
assert.strictEqual(contracts?.router, '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0');
const tokens = DEFAULT_TOKENS[31337];
assert(tokens.length >= 4, 'Should have at least 4 default tokens');
console.log('  ✓ Contract registry & token config passed');

// 4. Calldata Builder Tests
console.log('[Test 9] Calldata Builder:');
const calldata = buildSwapExactTokensCalldata({
  amountIn: 1000n,
  amountOutMin: 950n,
  path: ['0x1111111111111111111111111111111111111111', '0x2222222222222222222222222222222222222222'],
  to: '0x3333333333333333333333333333333333333333',
  deadline: 9999999999n
});
assert(calldata.startsWith('0x'), 'Calldata should be hex string');
console.log('  ✓ Calldata builder passed');

console.log('\n=============================================');
console.log('ALL PHASE 8 FRONTEND TESTS PASSED (100% OK)');
console.log('=============================================\n');
