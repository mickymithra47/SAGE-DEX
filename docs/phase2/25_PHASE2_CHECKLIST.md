# 25 — Phase 2 Mastery Verification Checklist

## Core Competency Checklist

### 1. Canonical ERC-20 & State Architecture
- [x] Masters all 6 canonical functions and 2 events of EIP-20.
- [x] Understands mapping storage slot computation for `balanceOf` and `allowance`.
- [x] Understands supply conservation invariant ($\sum \text{balances} = \text{totalSupply}$).
- [x] Knows how custom errors reduce gas on transfer reverts by over 80%.

### 2. Allowance & Approval Security
- [x] Explains approval race conditions and the front-running vector.
- [x] Understands `increaseAllowance` / `decreaseAllowance` mechanics.
- [x] Masters the zero-reset pattern (`approve(spender, 0)`).
- [x] Explains infinite allowance (`type(uint256).max`) gas optimization.

### 3. Return Value Anomalies & SafeERC20
- [x] Explains why USDT reverts in standard Solidity interfaces (0 bytes returndata).
- [x] Explains false-returning tokens (ZRX) and why ignoring bool returns causes loss.
- [x] Implements hand-tuned assembly `SafeTokenTransfer` with revert bubble-up.

### 4. Decimals & Multi-Decimal Precision Math
- [x] Understands that token balances are unsigned integers and decimals are metadata.
- [x] Explains the danger of 1:1 math between 6-decimal USDC and 18-decimal DAI.
- [x] Implements multi-decimal scaling to 18-decimal WAD (`scaleDecimals`, `toWad`, `fromWad`).
- [x] Masters directional rounding (`mulDivDown` for user outputs, `mulDivUp` for protocol fees).

### 5. Native ETH & WETH
- [x] Explains differences between native ETH value transfers and ERC-20 state mutations.
- [x] Masters canonical WETH9 deposit, withdraw, and fallback mechanics.
- [x] Verifies 1:1 WETH solvency invariant (`address(weth).balance == totalSupply`).

### 6. EIP-2612 Permit & EIP-712 Structured Signing
- [x] Explains EIP-712 domain separators, typehashes, and struct hashes.
- [x] Implements EIP-2612 `permit()` with deadline, nonce, and `ecrecover` validation.
- [x] Implements dynamic `DOMAIN_SEPARATOR` calculation to protect against hard-fork replays.
- [x] Explains Permit2 shared allowance infrastructure.

### 7. Adversarial Token Integration & Threat Modeling
- [x] Evaluated all 12 adversarial token types (Reentrant, Fee-on-Transfer, Rebasing, Blacklist, Pausable, Unusual Decimals, False-Return, No-Return, Reverting, Malicious Callback, Transfer Limits, Approval Race).
- [x] Implemented balance-delta accounting (`balanceAfter - balanceBefore`).
- [x] Defined explicit asset support policy (Categories A through F).
- [x] Built on-chain `TokenCompatibilityChecker` diagnostic engine.

### 8. Token Accounting & Donation Defense
- [x] Explains discrepancy between physical `balanceOf` and internal reserves.
- [x] Explains the token donation / share inflation exploit on empty vaults/pools.
- [x] Implements `sync()` and virtual share offset mitigations.
