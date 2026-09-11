// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Math
 * @notice Standard math utilities: min and Babylonian square root
 */
library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // Babylonian integer square root algorithm
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

/**
 * @title UQ112x112
 * @notice Library for handling binary fixed point numbers with 112 fractional bits.
 *         Used for computing time-weighted average price (TWAP) accumulators without precision loss.
 */
library UQ112x112 {
    uint224 private constant Q112 = 2 ** 112;

    // Encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // Never overflows
    }

    // Divide a UQ112x112 by a uint112, returning a UQ112x112
    function qdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
