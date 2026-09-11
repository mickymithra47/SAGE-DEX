// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerablePayer
 * @notice Flawed contract that ignores the boolean return value of low-level `call`.
 */
contract VulnerablePayer {
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasPaid;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function payout(address payable recipient) external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        balances[msg.sender] = 0;
        hasPaid[msg.sender] = true;

        // VULNERABILITY: Low-level call return value is NOT checked!
        // If recipient refuses the ETH (e.g. reverts in receive), contract still records payout!
        recipient.call{value: amount}("");
    }
}

/**
 * @title SecurePayer
 * @notice Hardened contract checking success and reverting on failed calls
 */
contract SecurePayer {
    error NoBalance();
    error TransferFailed();

    mapping(address => uint256) public balances;
    mapping(address => bool) public hasPaid;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function payout(address payable recipient) external {
        uint256 amount = balances[msg.sender];
        if (amount == 0) revert NoBalance();

        balances[msg.sender] = 0;
        hasPaid[msg.sender] = true;

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
}

/**
 * @title RejectingReceiver
 * @notice Mock contract that rejects all incoming ETH to trigger failed transfers
 */
contract RejectingReceiver {
    receive() external payable {
        revert("I refuse ETH");
    }
}
