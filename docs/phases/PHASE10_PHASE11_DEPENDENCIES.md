# Phase 10 to Phase 11 Dependency Analysis (Security Hardening, Adversarial Testing & Formal Verification)

## 1. Security Surfaces Requiring Phase 11 Hardening & Fuzzing

### A. AMM Core Invariants & Reserve Accounting
1. **`SagePair.sol`**:
   - Invariant enforcement: $(R_0 \cdot 1000 + \Delta x \cdot 997)(R_1 \cdot 1000 - \Delta y \cdot 1000) \ge R_0 R_1 \cdot 1000^2$.
   - First-liquidity inflation attack defense (`MINIMUM_LIQUIDITY = 1000` burned to `address(0)`).
   - Balance-delta measurement immunity against malicious balance inflation or fee-on-transfer tokens.
   - Flash swap optimistic execution callback safety and reentrancy locks.

### B. Router Execution & Authorization Security
2. **`SageRouter.sol`**:
   - Zero residual token/ETH router balance invariant after multi-hop execution.
   - Strict slippage tolerance enforcement (`amountOut >= amountOutMin`, `amountIn <= amountInMax`).
   - Temporal expiration deadlines (`block.timestamp <= deadline`).
3. **`Permit2.sol` & `SagePermitRouter.sol`**:
   - Unordered bitmap nonce replay protection (256 nonces per storage word).
   - EIP-712 cryptographic signature validity with strict low-s curve enforcement (EIP-2).
   - Spender, token, and chain ID cryptographic binding.

### C. Oracle & Manipulation Resistance
4. **`SageOracleEngine.sol` (TWAP)**:
   - Fixed-point UQ112x112 cumulative price accumulator monotonicity.
   - Multi-block manipulation cost under sliding observation windows.

### D. What Phase 11 Must NOT Modify
- Constant-product invariant formulas ($x \cdot y = k$).
- Stateless router architecture and direct pool-to-pool token transfers.
- Permit2 bitmap authorization mechanics.
- Client-side zero-floating-point `bigint` precision rules.
