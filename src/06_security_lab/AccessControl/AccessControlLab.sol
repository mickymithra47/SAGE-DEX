// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerableOwner
 * @notice Flawed access control: missing onlyOwner modifier or uninitialized owner
 */
contract VulnerableOwner {
    address public owner;
    uint256 public protocolFee;

    constructor() {
        owner = msg.sender;
    }

    // VULNERABILITY: Missing access control modifier!
    function setProtocolFee(uint256 newFee) external {
        protocolFee = newFee;
    }

    // VULNERABILITY: Unprotected owner change!
    function transferOwnership(address newOwner) external {
        owner = newOwner;
    }
}

/**
 * @title SecureOwner
 * @notice Hardened 2-step ownership transfer and strict access modifiers
 */
contract SecureOwner {
    error Unauthorized();
    error ZeroAddress();

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FeeUpdated(uint256 newFee);

    address public owner;
    address public pendingOwner;
    uint256 public protocolFee;

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function setProtocolFee(uint256 newFee) external onlyOwner {
        protocolFee = newFee;
        emit FeeUpdated(newFee);
    }

    // Two-step ownership transfer prevents accidental loss of control to wrong addresses
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert Unauthorized();
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}
