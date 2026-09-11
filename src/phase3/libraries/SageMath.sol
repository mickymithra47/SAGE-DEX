// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title SageMath
 * @notice Pure financial mathematics library for the Constant-Product AMM (x * y = k)
 */
library SageMath {
    error InsufficientAmount();
    error InsufficientLiquidity();
    error InsufficientInputAmount();
    error InsufficientOutputAmount();

    // Given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        if (amountA == 0) revert InsufficientAmount();
        if (reserveA == 0 || reserveB == 0) revert InsufficientLiquidity();
        amountB = (amountA * reserveB) / reserveA;
    }

    // Given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset with 0.3% fee
    // Formula: Δy = (997 * Δx * y) / (1000 * x + 997 * Δx)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        if (amountIn == 0) revert InsufficientInputAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // Given an output amount of an asset and pair reserves, returns the required input amount of the other asset with 0.3% fee
    // Formula: Δx = ceil( (1000 * x * Δy) / (997 * (y - Δy)) )
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountIn) {
        if (amountOut == 0) revert InsufficientOutputAmount();
        if (reserveIn == 0 || reserveOut == 0 || amountOut >= reserveOut) revert InsufficientLiquidity();

        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1; // Round up to ensure invariant is strictly satisfied
    }
}
