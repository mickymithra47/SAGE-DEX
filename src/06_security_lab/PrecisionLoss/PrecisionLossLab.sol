// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerableFeeCalculator
 * @notice Flawed arithmetic calculation: performs division BEFORE multiplication, causing severe precision loss.
 */
contract VulnerableFeeCalculator {
    uint256 public constant FEE_DENOMINATOR = 10_000; // basis points

    // VULNERABILITY: Division before multiplication!
    // If amount < FEE_DENOMINATOR, (amount / FEE_DENOMINATOR) truncates to 0!
    // Result: fee is 0, completely depriving protocol of fees.
    function calculateFeeVulnerable(uint256 amount, uint256 feeBps) external pure returns (uint256 fee) {
        fee = (amount / FEE_DENOMINATOR) * feeBps;
    }
}

/**
 * @title SecureFeeCalculator
 * @notice Hardened calculation: multiplies FIRST, then divides, with optional rounding up/down specification.
 */
contract SecureFeeCalculator {
    uint256 public constant FEE_DENOMINATOR = 10_000;

    // Multiplication before division preserves integer precision
    function calculateFeeDown(uint256 amount, uint256 feeBps) public pure returns (uint256 fee) {
        fee = (amount * feeBps) / FEE_DENOMINATOR;
    }

    // Rounds UP (favors protocol solvency in AMMs)
    function calculateFeeUp(uint256 amount, uint256 feeBps) public pure returns (uint256 fee) {
        uint256 numerator = amount * feeBps;
        if (numerator == 0) return 0;
        fee = (numerator + FEE_DENOMINATOR - 1) / FEE_DENOMINATOR;
    }
}
