// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title MappingSlotCalculator
 * @notice Demonstrates EVM storage slot location formulas for mappings, arrays, and nested structures.
 *
 * EVM STORAGE FORMULAS:
 * 1. Simple mapping(K => V) declared at slot `p`:
 *    Location of key `k` is: keccak256(abi.encode(k, p)) [or keccak256(bytes32(k) ++ bytes32(p))]
 *
 * 2. Nested mapping(K1 => mapping(K2 => V)) at slot `p`:
 *    Location of `k1, k2` is: keccak256(abi.encode(k2, keccak256(abi.encode(k1, p))))
 *
 * 3. Dynamic array T[] at slot `p`:
 *    - Slot `p` stores the `length` of the array.
 *    - Element `arr[i]` is stored at: `keccak256(abi.encode(p)) + i` (if each element takes 1 full slot).
 */
contract MappingSlotCalculator {
    // Slot 0
    mapping(address => uint256) public balances;

    // Slot 1
    mapping(address => mapping(address => uint256)) public allowances;

    // Slot 2
    uint256[] public dynamicArray;

    function setBalance(address user, uint256 amount) external {
        balances[user] = amount;
    }

    function setAllowance(address owner, address spender, uint256 amount) external {
        allowances[owner][spender] = amount;
    }

    function pushArray(uint256 value) external {
        dynamicArray.push(value);
    }

    // Formula implementations:
    function computeMappingSlot(address key, uint256 slot) public pure returns (bytes32) {
        return keccak256(abi.encode(key, slot));
    }

    function computeNestedMappingSlot(address key1, address key2, uint256 slot) public pure returns (bytes32) {
        bytes32 innerSlot = keccak256(abi.encode(key1, slot));
        return keccak256(abi.encode(key2, innerSlot));
    }

    function computeArrayElementSlot(uint256 arraySlot, uint256 index) public pure returns (bytes32) {
        bytes32 baseSlot = keccak256(abi.encode(arraySlot));
        return bytes32(uint256(baseSlot) + index);
    }

    // Assembly verification: reads exact 32 bytes from computed slot
    function readStorageSlotAssembly(bytes32 slot) external view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }
}
