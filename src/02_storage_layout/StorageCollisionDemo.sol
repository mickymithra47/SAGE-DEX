// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title StorageCollisionDemo
 * @notice Demonstrates storage slot collision bugs in proxy/upgradeable architectures.
 *
 * SCENARIO:
 * Implementation V1 defines:
 * Slot 0: address owner
 * Slot 1: uint256 feeRate
 *
 * Flawed Implementation V2 incorrectly inserts a new variable at the top:
 * Slot 0: bool isPaused (CORRUPTS OWNER!)
 * Slot 1: address owner (WAS feeRate!)
 * Slot 2: uint256 feeRate
 */

contract ImplementationV1 {
    address public owner;     // Slot 0
    uint256 public feeRate;   // Slot 1

    function initialize(address _owner, uint256 _feeRate) external {
        owner = _owner;
        feeRate = _feeRate;
    }

    function setFeeRate(uint256 _feeRate) external {
        feeRate = _feeRate;
    }
}

contract FlawedImplementationV2 {
    bool public isPaused;     // Slot 0 -> OVERWRITES Slot 0 (where owner was stored!)
    address public owner;     // Slot 1 -> OVERWRITES Slot 1 (where feeRate was stored!)
    uint256 public feeRate;   // Slot 2

    function pause() external {
        isPaused = true;
    }
}

contract CorrectImplementationV2 {
    // Preserves existing layout in exact order!
    address public owner;     // Slot 0
    uint256 public feeRate;   // Slot 1
    // New variables MUST be appended at the end:
    bool public isPaused;     // Slot 2

    function pause() external {
        isPaused = true;
    }
}

contract CollisionProxy {
    address public currentImplementation; // Slot 0 of proxy itself if not using EIP-1967!
    address public owner;                 // Slot 1
    uint256 public feeRate;               // Slot 2
    bool public isPaused;                 // Slot 3

    function setImplementation(address _impl) external {
        currentImplementation = _impl;
    }

    receive() external payable {}

    fallback() external payable {
        address impl = currentImplementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
