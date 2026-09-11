# 18 — Oracle Read API & Consultation Primitives

## 1. Core Oracle Methods

```solidity
interface ISageOracle {
    // Records current cumulative price observation
    function update(address pair) external;

    // Consults historical TWAP over lookbackPeriodSeconds and returns equivalent amountOut
    function consult(
        address pair,
        address tokenIn,
        uint256 amountIn,
        uint32 lookbackPeriodSeconds
    ) external view returns (uint256 amountOutTWAP);

    // Queries current instantaneous spot price in WAD
    function getSpotPriceWad(address pair, address tokenIn) external view returns (uint256 spotPriceWad);

    // Fetches the most recent observation struct
    function getLatestObservation(address pair) external view returns (Observation memory);
}
```
