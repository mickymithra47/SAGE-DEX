# 71 — Phase 9 to Phase 10 Dependency Report (Security Hardening & Adversarial Verification)

## 1. Stabilized Phase 9 Subsystems
- Complete TypeScript + Viem + PostgreSQL read/indexing pipeline.
- Reorg detection, block cursor checkpointing, and atomic state rollback.
- Event decoding and canonical swap interpretation (`Swap`, `Mint`, `Burn`, `Sync`, `PairCreated`, `Transfer`).
- Historical OHLCV candlestick aggregation and 24h volume/fee metrics.
- GraphQL & REST API resolvers with cursor-based pagination.
- Automated on-chain reconciliation monitor.

---

## 2. Comprehensive Security Review Surface for Phase 10 (Security Hardening, Adversarial Testing & Formal Verification)

### A. Protocol Contracts Requiring Formal Verification & Fuzzing
1. **`SagePair.sol`**:
   - Invariant satisfaction: $(R_0 \cdot 1000 + \Delta x \cdot 997)(R_1 \cdot 1000 - \Delta y \cdot 1000) \ge R_0 R_1 \cdot 1000^2$.
   - First-liquidity inflation resistance (`MINIMUM_LIQUIDITY = 1000`).
   - Slot 3 reserve packing and reentrancy lock.
   - Flash swap optimistic transfer callbacks.
2. **`SageRouter.sol`**:
   - Zero residual token / ETH balances in router post-execution.
   - Slippage threshold enforcement (`amountOut >= amountOutMin`, `amountIn <= amountInMax`).
   - Temporal deadline expiration checks (`block.timestamp <= deadline`).
3. **`Permit2.sol` & `SagePermitRouter.sol`**:
   - Bitmap unordered nonce replay protection (256 nonces/word).
   - EIP-712 cryptographic signature validation with strict low-s signature curve verification (EIP-2).
   - Spender and recipient address binding.
4. **`SageOracleEngine.sol` & `TWAP`**:
   - UQ112x112 fixed-point cumulative price monotonicity.
   - Manipulation cost resistance over sliding lookback time windows.

### B. External Call & Token Attack Surfaces
- Fee-on-transfer tokens (safely supported via pair balance-delta measurement).
- Rebasing tokens (reconciled via `sync()` and `skim()`).
- ERC-777 / ERC-1363 reentrant tokens (defended by transient/storage reentrancy locks).
- Non-standard ERC-20s (zero-return / boolean returns handled by Yul safe transfer library).

### C. What Phase 10 Must NOT Modify
- Core AMM invariant math ($x \cdot y = k$).
- Stateless router execution chaining and direct pool-to-pool token transfers.
- Permit2 bitmap authorization mechanics.
- Client-side zero-floating-point `bigint` math.
