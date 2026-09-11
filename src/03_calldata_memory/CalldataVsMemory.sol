// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title CalldataVsMemory
 * @notice Demonstrates EVM differences between `calldata` and `memory`:
 *         1. Calldata: Read-only, immutable byte slice pointing directly to transaction input data.
 *            - Zero-copy (no memory expansion or allocation needed).
 *            - Allows zero-cost slicing: `arr[10:20]`.
 *         2. Memory: Mutable scratchpad allocated during EVM execution.
 *            - Copying large dynamic payloads into memory incurs `CALLDATACOPY` opcodes + quadratic memory expansion gas!
 */
contract CalldataVsMemory {
    // Computes sum using calldata (no memory allocation)
    function sumCalldata(uint256[] calldata data) external pure returns (uint256 total) {
        uint256 len = data.length;
        for (uint256 i = 0; i < len; ) {
            total += data[i];
            unchecked {
                ++i;
            }
        }
    }

    // Computes sum using memory (forces copying calldata to memory + memory expansion)
    function sumMemory(uint256[] memory data) external pure returns (uint256 total) {
        uint256 len = data.length;
        for (uint256 i = 0; i < len; ) {
            total += data[i];
            unchecked {
                ++i;
            }
        }
    }

    // Calldata slice demonstration (O(1) pointer slice, 0 memory allocated)
    function sliceCalldataSum(uint256[] calldata data, uint256 start, uint256 end) external pure returns (uint256 total) {
        uint256[] calldata slice = data[start:end];
        uint256 len = slice.length;
        for (uint256 i = 0; i < len; ) {
            total += slice[i];
            unchecked {
                ++i;
            }
        }
    }
}

/**
 * @title FreeMemoryPointerDemo
 * @notice Explores Solidity's memory layout:
 *         - 0x00 - 0x3f (64 bytes): Scratch space for hashing methods
 *         - 0x40 - 0x5f (32 bytes): Free memory pointer (initialized to 0x80)
 *         - 0x60 - 0x7f (32 bytes): Zero slot (used as initial value for dynamic memory arrays)
 *         - 0x80+: Allocated memory space
 */
contract FreeMemoryPointerDemo {
    function inspectFreeMemoryPointer() external pure returns (uint256 fmpBefore, uint256 fmpAfter) {
        assembly {
            fmpBefore := mload(0x40)
        }

        // Allocate a new dynamic array in memory
        uint256[] memory arr = new uint256[](5);
        arr[0] = 42;

        assembly {
            fmpAfter := mload(0x40)
        }
    }

    function calculateMemoryExpansionGas(uint256 words) external pure returns (uint256 gasCost) {
        // EVM yellow paper formula: C_mem(a) = 3 * a + floor(a^2 / 512)
        gasCost = 3 * words + (words * words) / 512;
    }
}
