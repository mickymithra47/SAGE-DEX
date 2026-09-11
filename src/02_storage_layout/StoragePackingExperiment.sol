// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title StoragePackingExperiment
 * @notice Demonstrates how Solidity packs variables <= 32 bytes into single 32-byte storage slots
 *
 * UNPACKED LAYOUT (consumes 4 distinct 32-byte slots):
 * Slot 0: uint256 a (32 bytes)
 * Slot 1: uint128 b (16 bytes, but next item does not fit -> padded)
 * Slot 2: uint256 c (32 bytes)
 * Slot 3: bool d    (1 byte)
 *
 * PACKED LAYOUT (consumes only 2 slots):
 * Slot 0: uint128 x (16 bytes) + uint64 y (8 bytes) + address z (20 bytes)?
 *         Wait: 16 + 8 = 24 bytes. Address is 20 bytes -> 24 + 20 = 44 > 32.
 *         So: uint128 x (16 bytes) + uint64 y (8 bytes) + uint32 z (4 bytes) + uint32 w (4 bytes) = 32 bytes (Slot 0)
 *         Slot 1: address owner (20 bytes) + bool flag (1 byte) + uint8 state (1 byte) = 22 bytes (Slot 1)
 */
contract UnpackedStorage {
    uint256 public a; // Slot 0
    uint128 public b; // Slot 1
    uint256 public c; // Slot 2
    bool public d;    // Slot 3

    function setAll(uint256 _a, uint128 _b, uint256 _c, bool _d) external {
        a = _a; // SSTORE Slot 0 (20k or 2.9k gas)
        b = _b; // SSTORE Slot 1
        c = _c; // SSTORE Slot 2
        d = _d; // SSTORE Slot 3
    }
}

contract PackedStorage {
    // Slot 0: 16 + 8 + 4 + 4 = 32 bytes
    uint128 public x; // offset 0
    uint64 public y;  // offset 16
    uint32 public z;  // offset 24
    uint32 public w;  // offset 28

    // Slot 1: 20 + 1 + 1 = 22 bytes (10 bytes unused)
    address public owner; // offset 0
    bool public flag;     // offset 20
    uint8 public state;   // offset 21

    function setSlot0(uint128 _x, uint64 _y, uint32 _z, uint32 _w) external {
        // All 4 variables are written into Slot 0 using 1 warm/cold SSTORE with bitwise masking!
        x = _x;
        y = _y;
        z = _z;
        w = _w;
    }

    function setSlot1(address _owner, bool _flag, uint8 _state) external {
        owner = _owner;
        flag = _flag;
        state = _state;
    }
}
