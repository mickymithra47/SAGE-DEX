# AUDIT_SMART_CONTRACTS.md
# SAGE PROTOCOL — SMART CONTRACTS SECURITY & CORRECTNESS AUDIT
**Scope**: Core Contracts in `src/phase2/` and `src/phase3/`  

---

## 1. Scope of Inspected Contracts

| Contract | File Path | Lines of Code | Purpose |
| :--- | :--- | :---: | :--- |
| **`SagePair`** | `src/phase3/core/SagePair.sol` | 211 | Canonical constant-product AMM pool engine |
| **`SageFactory`** | `src/phase3/core/SageFactory.sol` | 66 | CREATE2 deterministic pair factory & registry |
| **`SageERC20`** | `src/phase3/core/SageERC20.sol` | 89 | LP share token standard ERC-20 implementation |
| **`SafeTokenTransfer`**| `src/phase2/libraries/SafeTokenTransfer.sol`| 86 | Low-level token interaction with USDT & non-standard support |
| **`WETH`** | `src/phase2/token/WETH.sol` | 51 | Canonical Wrapped Ether implementation |
| **`ERC20Token`** | `src/phase2/token/ERC20Token.sol` | 44 | Configurable decimal test token implementation |
| **`PermitToken`** | `src/phase2/token/PermitToken.sol` | 76 | Native EIP-2612 permit test token |
| **`TokenRegistry`** | `src/phase2/token/TokenRegistry.sol` | 48 | On-chain token metadata and verification registry |

---

## 2. Security & Correctness Analysis

### 2.1 Constant Product AMM Invariant & Fee Calculation
In `SagePair.sol`, the constant product invariant check during `swap` is implemented as:
```solidity
uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
if (balance0Adjusted * balance1Adjusted < uint256(_reserve0) * _reserve1 * (1000 ** 2)) {
    revert KInvariantViolation();
}
```
- **Arithmetic Safety**: Under Solidity 0.8.26, checked arithmetic protects against underflows. For maximal reserves $R_0, R_1 \le 2^{112}-1$, $(R_0 \cdot 1000) \cdot (R_1 \cdot 1000) \approx 2^{224} \cdot 10^6 < 2^{256}$, guaranteeing no arithmetic overflow occurs within `uint256`.
- **Fee Precision**: Subtracting `amount0In * 3` from `balance0 * 1000` is algebraically identical to multiplying balance by 1000 and taking a 3/1000 (0.30% = 30 bps) LP fee.

### 2.2 Reentrancy Protection
- `SagePair` implements a custom mutex lock modifier:
```solidity
uint256 private unlocked = 1;
modifier lock() {
    if (unlocked != 1) revert Locked();
    unlocked = 0;
    _;
    unlocked = 1;
}
```
- All state-mutating functions (`mint`, `burn`, `swap`, `skim`, `sync`) apply the `lock` modifier.
- Flash swap callbacks via `ISageCallee(to).sageCall(...)` execute within the optimistic swap block while `unlocked == 0`, strictly preventing any reentrant calls back into the pair contract.

### 2.3 First-Provider Inflation Attack Protection
- `SagePair.mint` enforces permanent burning of the first `MINIMUM_LIQUIDITY = 1000` wei of LP shares to `address(0)` on initial deposit:
```solidity
if (_totalSupply == 0) {
    liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
    _mint(address(0), MINIMUM_LIQUIDITY);
}
```
- This permanently prevents the classic ERC-4626 / Uniswap V2 share inflation attack where an attacker inflates the price of 1 wei of share to steal subsequent depositor funds.

### 2.4 Low-Level Assembly in `SafeTokenTransfer.sol`
```solidity
if gt(returndata_size, 0) {
    returndatacopy(0x00, 0x00, 0x20)
    let returnedVal := mload(0x00)
    if iszero(returnedVal) {
        revert(add(customError, 0x20), mload(customError))
    }
}
```
- Correctly handles tokens returning 0-byte returndata on success (such as USDT) as well as tokens returning standard 32-byte boolean `true`.
- Correctly treats boolean `false` return value as an explicit failure.

---

## 3. Findings & Recommendations

### [LOW] Non-Standard Returndata Size Edge Case in `SafeTokenTransfer`
- **Issue**: If a non-compliant token returns between 1 and 31 bytes of returndata, `returndatacopy(0x00, 0x00, 0x20)` copies past the returned payload, reading trailing memory in the scratch space.
- **Remediation**: Check `if lt(returndata_size, 32)` or use standard OpenZeppelin `SafeERC20` patterns.
