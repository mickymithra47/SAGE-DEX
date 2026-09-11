// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Project8_YulOptimizedMath
 * @notice Mini-Project 8: Yul-optimized fixed point mathematics library (WAD = 1e18)
 */
contract Project8_YulOptimizedMath {
    uint256 public constant WAD = 1e18;

    error Overflow();
    error ZeroDenominator();

    // WAD Multiplication: (x * y) / 1e18
    function wmul(uint256 x, uint256 y) public pure returns (uint256 z) {
        assembly {
            // Check overflow: if x != 0, (x * y) / x == y
            let prod := mul(x, y)
            if iszero(or(iszero(x), eq(div(prod, x), y))) {
                // Revert with Overflow()
                mstore(0x00, 0x35278d12) // Overflow() selector
                revert(0x1c, 0x04)
            }
            z := div(prod, 1000000000000000000)
        }
    }

    // WAD Division: (x * 1e18) / y
    function wdiv(uint256 x, uint256 y) public pure returns (uint256 z) {
        if (y == 0) revert ZeroDenominator();

        assembly {
            let xWad := mul(x, 1000000000000000000)
            if iszero(or(iszero(x), eq(div(xWad, x), 1000000000000000000))) {
                mstore(0x00, 0x35278d12)
                revert(0x1c, 0x04)
            }
            z := div(xWad, y)
        }
    }

    // Square root via Babylonian method in pure Yul
    function sqrtYul(uint256 y) public pure returns (uint256 z) {
        assembly {
            if gt(y, 3) {
                z := y
                let x := add(div(y, 2), 1)
                for {} lt(x, z) {} {
                    z := x
                    x := div(add(div(y, x), x), 2)
                }
            }
            if and(iszero(gt(y, 3)), iszero(iszero(y))) {
                z := 1
            }
        }
    }

    // Baseline Solidity implementation for comparison
    function wmulSolidity(uint256 x, uint256 y) external pure returns (uint256) {
        return (x * y) / WAD;
    }
}
