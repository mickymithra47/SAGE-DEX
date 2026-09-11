// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title ISageOracle
 * @notice Interface for querying TWAP observations, lookback periods, and cumulative prices
 */
interface ISageOracle {
    struct Observation {
        uint32 timestamp;
        uint256 price0Cumulative;
        uint256 price1Cumulative;
    }

    function update(address pair) external;

    function consult(
        address pair,
        address tokenIn,
        uint256 amountIn,
        uint32 lookbackPeriodSeconds
    ) external view returns (uint256 amountOutTWAP);

    function getSpotPriceWad(address pair, address tokenIn) external view returns (uint256 spotPriceWad);

    function getLatestObservation(address pair) external view returns (Observation memory);
}
