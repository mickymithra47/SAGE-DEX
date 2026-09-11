# AUDIT_LIQUIDITY.md
# SAGE PROTOCOL — LIQUIDITY & LP POSITION ENGINE AUDIT
**Scope**: `src/phase4/` (`SageLPAccountingEngine.sol`, `LPPositionMath.sol`, `ISageLPPosition.sol`)  

---

## 1. Liquidity Lifecycle Architecture

### 1.1 Initial Liquidity Deposit
- Formula: $L_0 = \sqrt{a_0 \cdot a_1} - 1000$
- First deposit locks $1000\text{ wei}$ of LP tokens permanently to `address(0)` in `SagePair.sol` and `LPPositionMath.calculateInitialLiquidity()`.
- Prevents price manipulation via share denominator manipulation.

### 1.2 Proportional Share Allocation
- Formula: $L = \min\left( \frac{a_0 \cdot S}{R_0}, \frac{a_1 \cdot S}{R_1} \right)$
- Truncates downwards so no depositor receives more shares than their minimum contributing side justifies.

### 1.3 Liquidity Redemption (Burn)
- Formula: $a_0 = \frac{L \cdot R_0}{S}, \quad a_1 = \frac{L \cdot R_1}{S}$
- Correctly returns proportional share of both pool reserves upon burning LP tokens.

---

## 2. Findings & Vulnerabilities

### [CRITICAL] Decimal Scaling Corruption in `LPPositionMath.calculatePositionValue`
- **Location**: `src/phase4/libraries/LPPositionMath.sol#L91-L106`
- **Vulnerability**:
```solidity
function calculatePositionValue(
    uint256 userShares,
    uint256 totalShares,
    uint256 reserve0,
    uint256 reserve1,
    uint256 price0Wad,
    uint256 price1Wad
) internal pure returns (uint256 totalValueWad) {
    if (totalShares == 0 || userShares == 0) return 0;
    uint256 claim0 = (userShares * reserve0) / totalShares;
    uint256 claim1 = (userShares * reserve1) / totalShares;

    uint256 val0 = (claim0 * price0Wad) / WAD;
    uint256 val1 = (claim1 * price1Wad) / WAD;
    totalValueWad = val0 + val1;
}
```
- **Root Cause**: `claim0` is denominated in token0's native decimals (e.g. 6 decimals for USDC), while `claim1` is denominated in token1's native decimals (e.g. 18 decimals for WETH).
- When computing `val0 = (claim0 * price0Wad) / WAD`, the result `val0` remains in token0 decimals ($10^6$). When computing `val1 = (claim1 * price1Wad) / WAD`, `val1` is in token1 decimals ($10^{18}$).
- Line 105 directly executes `totalValueWad = val0 + val1`, adding $10^6$ units directly to $10^{18}$ units!
- **Impact**: For a USDC (6 dec) / WETH (18 dec) pool with $1,000 of USDC and $1,000 of WETH:
  - `val0` = $1,000 \times 10^6$ = $1,000,000,000$
  - `val1` = $1,000 \times 10^{18}$ = $1,000,000,000,000,000,000,000$
  - `totalValueWad` returns $1,000,000,001,000,000,000,000$ (representing $\$1,000.000001$) instead of $\$2,000 \times 10^{18}$! The USDC position value is virtually erased by $10^{12}\times$.
- **Remediation**: Normalize `claim0` and `claim1` to 18 decimals (WAD) before calculating valuation, or accept `uint8 decimals0, uint8 decimals1` parameters:
```solidity
uint256 claim0Wad = SagePricingLibrary.normalizeDecimals(claim0, decimals0, 18);
uint256 claim1Wad = SagePricingLibrary.normalizeDecimals(claim1, decimals1, 18);
uint256 val0 = (claim0Wad * price0Wad) / WAD;
uint256 val1 = (claim1Wad * price1Wad) / WAD;
totalValueWad = val0 + val1;
```

---

## 3. Position Viewer Quality
- `SageLPAccountingEngine.getPosition()`, `quoteAddLiquidity()`, and `quoteRemoveLiquidity()` are correctly implemented as read-only view helpers.
- Test suites `test/phase4/` pass with 100% assertions for standard liquidity operations.
