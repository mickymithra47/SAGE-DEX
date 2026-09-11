// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title YulArithmetic
 * @notice Demonstrates low-level arithmetic and bitwise operations in Yul / inline assembly
 */
contract YulArithmetic {
    error MathOverflow();
    error DivisionByZero();

    // Fast addition in Yul with overflow check
    function safeAdd(uint256 x, uint256 y) external pure returns (uint256 z) {
        bytes4 sel = MathOverflow.selector;
        assembly {
            z := add(x, y)
            if lt(z, x) {
                mstore(0x00, sel)
                revert(0x00, 0x04)
            }
        }
    }

    // Unchecked add in Yul (saves gas when overflow is impossible)
    function uncheckedAdd(uint256 x, uint256 y) external pure returns (uint256 z) {
        assembly {
            z := add(x, y)
        }
    }

    // Fast multiply-divide in Yul: (a * b) / denominator
    function mulDivDown(uint256 a, uint256 b, uint256 denominator) external pure returns (uint256 result) {
        if (denominator == 0) revert DivisionByZero();

        bytes4 sel = MathOverflow.selector;
        assembly {
            let prod := mul(a, b)
            // Check for multiplication overflow: prod / a == b
            if iszero(or(iszero(a), eq(div(prod, a), b))) {
                mstore(0x00, sel)
                revert(0x00, 0x04)
            }
            result := div(prod, denominator)
        }
    }

    // Bitwise packing in Yul: packs two uint128s into a single bytes32
    function packTwoUint128(uint128 high, uint128 low) external pure returns (bytes32 packed) {
        assembly {
            packed := or(shl(128, high), low)
        }
    }

    // Bitwise unpacking in Yul: unpacks a bytes32 into two uint128s
    function unpackTwoUint128(bytes32 packed) external pure returns (uint128 high, uint128 low) {
        assembly {
            high := shr(128, packed)
            low := and(packed, 0xffffffffffffffffffffffffffffffff)
        }
    }
}
