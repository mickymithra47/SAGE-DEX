# AUDIT_ORACLE.md
# SAGE PROTOCOL — PRICING & ORACLE ENGINE AUDIT
**Scope**: `src/phase5/` (`SageOracleEngine.sol`, `SagePricingLibrary.sol`, `ISageOracle.sol`)  

---

## 1. Architecture of the Oracle Subsystem

The oracle engine is divided into three key capabilities:
1. **Spot Pricing & Multi-Hop Quoter**: `SagePricingLibrary.getAmountsOut()` & `getAmountsIn()`
2. **TWAP Accumulator Engine**: `SageOracleEngine.sol` tracking historical cumulative prices in `Observation` structs.
3. **Analytical Price Impact Modeling**: `SagePricingLibrary.calculatePriceImpactBps()`

---

## 2. Security Analysis of Price Feeds

### 2.1 Spot Price vs TWAP Usage Boundary
- **Spot Price (`getSpotPriceWad`)**: Used strictly for frontend display and quoter estimation (`SagePricingLibrary`).
- **TWAP (`consult`)**: Used for time-weighted average price derivation over a configurable lookback window ($\Delta t \ge \text{lookbackPeriodSeconds}$).
- **Audit Verification**: The core router contracts (`SageRouter.sol` and `SagePermitRouter.sol`) execute trades based on actual pool reserves and user-specified `amountOutMin` / `amountInMax` slippage tolerances, **NOT** on instantaneous spot price oracles. This strictly prevents oracle flash-loan manipulation attacks on trade execution.

---

### 2.2 TWAP Observation Engine & Binary Search Lookup
In `SageOracleEngine.sol`:
```solidity
function _findObservationBeforeOrAt(address pair, uint32 targetTimestamp)
    internal
    view
    returns (Observation memory obs)
{
    uint32[] storage tsList = observationTimestamps[pair];
    if (tsList.length == 0) revert Uninitialized();

    uint256 low = 0;
    uint256 high = tsList.length - 1;
    uint256 bestIdx = 0;

    while (low <= high) {
        uint256 mid = (low + high) / 2;
        if (tsList[mid] <= targetTimestamp) {
            bestIdx = mid;
            low = mid + 1;
        } else {
            if (mid == 0) break;
            high = mid - 1;
        }
    }

    uint32 chosenTs = tsList[bestIdx];
    obs = observations[pair][chosenTs];
}
```

- **Algorithm**: $O(\log N)$ binary search over sorted timestamp arrays.
- **Edge Cases**:
  - Empty array reverts with `Uninitialized()`.
  - Zero elapsed time between target and current observation reverts with `InsufficientHistory()`.
  - Target timestamp older than the oldest observation selects `bestIdx = 0` (oldest available observation).

---

### 2.3 Intra-Block Pending Price Accumulation
In `_getCurrentCumulativePrices`:
```solidity
if (blockTimestampLast != blockTimestamp && r0 != 0 && r1 != 0) {
    unchecked {
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        price0Cumulative += uint256(UQ112x112.encode(r1).qdiv(r0)) * timeElapsed;
        price1Cumulative += uint256(UQ112x112.encode(r0).qdiv(r1)) * timeElapsed;
    }
}
```
- If an oracle query occurs in a block where swaps have not yet happened, it calculates the pending cumulative addition for the elapsed seconds since `blockTimestampLast`.
- This ensures high fidelity and prevents stale cumulative readings.

---

## 3. Findings & Recommendations

### [INFORMATIONAL] Unbounded `observationTimestamps` Storage Array
- Each `update()` call pushes a new `uint32` timestamp to the pair's timestamp array.
- For high-frequency updates, storage expands indefinitely.
- **Recommendation**: In production mainnet, consider a fixed-size ring buffer (e.g. 65,536 observation circular buffer like Uniswap V3) to bound storage and prevent unbounded state growth.
