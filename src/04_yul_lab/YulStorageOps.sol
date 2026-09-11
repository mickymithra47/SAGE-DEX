// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title YulStorageOps
 * @notice Demonstrates direct SLOAD / SSTORE / TLOAD / TSTORE manipulation in inline assembly
 */
contract YulStorageOps {
    // Standard persistent storage slot 0
    uint256 public persistentValue;

    // Read arbitrary storage slot
    function getSlot(bytes32 slot) external view returns (bytes32 val) {
        assembly {
            val := sload(slot)
        }
    }

    // Write arbitrary storage slot
    function setSlot(bytes32 slot, bytes32 val) external {
        assembly {
            sstore(slot, val)
        }
    }

    // Transient storage read (EIP-1153, Cancun EVM)
    function getTransientSlot(bytes32 slot) external view returns (bytes32 val) {
        assembly {
            val := tload(slot)
        }
    }

    // Transient storage write (EIP-1153, Cancun EVM)
    function setTransientSlot(bytes32 slot, bytes32 val) external {
        assembly {
            tstore(slot, val)
        }
    }
}

/**
 * @title YulCallForwarder
 * @notice Demonstrates low-level proxy forwarding in pure Yul
 */
contract YulCallForwarder {
    address public immutable target;

    constructor(address _target) {
        target = _target;
    }

    receive() external payable {}

    fallback() external payable {
        address _target = target;
        assembly {
            // Copy calldata to memory at position 0
            calldatacopy(0x00, 0x00, calldatasize())

            // Delegatecall target with all available gas
            let success := delegatecall(gas(), _target, 0x00, calldatasize(), 0x00, 0x00)

            // Copy returndata to memory at position 0
            returndatacopy(0x00, 0x00, returndatasize())

            switch success
            case 0 {
                // Revert with returned error bytes
                revert(0x00, returndatasize())
            }
            default {
                // Return data
                return(0x00, returndatasize())
            }
        }
    }
}

/**
 * @title YulVsSolidityBenchmark
 * @notice Side-by-side benchmark of common operations in Solidity vs Yul
 */
contract YulVsSolidityBenchmark {
    // 1. Solidity Keccak256 of two addresses
    function hashSolidity(address a, address b) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    // 2. Yul Keccak256 of two addresses (uses scratch space 0x00..0x3f, avoids memory allocation)
    function hashYul(address a, address b) external pure returns (bytes32 result) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            result := keccak256(0x0c, 0x34) // 20 bytes + 32 bytes or 20 bytes + 20 bytes = 40 bytes
        }
    }
}
