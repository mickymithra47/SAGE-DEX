// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title TokenAccountingMath
 * @notice Fixed-point arithmetic and decimal scaling library for multi-decimal token pairs.
 */
library TokenAccountingMath {
    error MathOverflow();
    error ZeroDenominator();

    uint256 internal constant WAD = 1e18;

    // Scales an amount from sourceDecimals to targetDecimals
    function scaleDecimals(
        uint256 amount,
        uint8 sourceDecimals,
        uint8 targetDecimals
    ) internal pure returns (uint256) {
        if (sourceDecimals == targetDecimals) {
            return amount;
        } else if (sourceDecimals < targetDecimals) {
            uint256 factor = 10 ** (targetDecimals - sourceDecimals);
            return amount * factor;
        } else {
            uint256 factor = 10 ** (sourceDecimals - targetDecimals);
            return amount / factor;
        }
    }

    // Converts any token amount to standard 18-decimal WAD
    function toWad(uint256 amount, uint8 tokenDecimals) internal pure returns (uint256) {
        return scaleDecimals(amount, tokenDecimals, 18);
    }

    // Converts 18-decimal WAD amount back to token native decimals
    function fromWad(uint256 wadAmount, uint8 tokenDecimals) internal pure returns (uint256) {
        return scaleDecimals(wadAmount, 18, tokenDecimals);
    }

    // Multiply-Divide with explicit rounding direction
    function mulDivDown(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        if (denominator == 0) revert ZeroDenominator();
        assembly {
            let prod := mul(a, b)
            if iszero(or(iszero(a), eq(div(prod, a), b))) {
                // Store MathOverflow selector
                mstore(0x00, 0x73b281b3)
                revert(0x00, 0x04)
            }
            result := div(prod, denominator)
        }
    }

    function mulDivUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        if (denominator == 0) revert ZeroDenominator();
        uint256 prod = a * b;
        if (a != 0 && prod / a != b) revert MathOverflow();
        if (prod == 0) return 0;
        return (prod + denominator - 1) / denominator;
    }
}
