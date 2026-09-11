// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IReceiver {
    function notify(uint256 amount) external;
}

/**
 * @title VulnerableCallbackReceiver
 * @notice Flawed protocol that relies on state flags modified *during* an untrusted callback
 */
contract VulnerableCallbackReceiver {
    mapping(address => uint256) public balances;
    bool public callbackCompleted;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // VULNERABILITY: Invokes external callback while state is inconsistent
    function performAction(address receiver, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient");

        // External callback before deducting balance
        IReceiver(receiver).notify(amount);

        // Deducts balance only after callback
        balances[msg.sender] -= amount;
    }
}

contract MaliciousReceiver is IReceiver {
    VulnerableCallbackReceiver public immutable target;
    uint256 public attackCount;

    constructor(address _target) {
        target = VulnerableCallbackReceiver(_target);
    }

    function notify(uint256 amount) external override {
        attackCount++;
        // Reenters or calls another function assuming old balance
    }
}

/**
 * @title SecureCallbackReceiver
 * @notice Hardened contract enforcing CEI and strictly isolated reentrancy locks
 */
contract SecureCallbackReceiver {
    error InsufficientBalance();
    error ReentrantCall();

    mapping(address => uint256) public balances;
    uint256 private _status = 1;

    modifier nonReentrant() {
        if (_status == 2) revert ReentrantCall();
        _status = 2;
        _;
        _status = 1;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function performAction(address receiver, uint256 amount) external nonReentrant {
        if (balances[msg.sender] < amount) revert InsufficientBalance();

        // 1. Update state first
        balances[msg.sender] -= amount;

        // 2. Safe external call
        IReceiver(receiver).notify(amount);
    }
}
