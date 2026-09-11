// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IProtocolCallback {
    function onCallback(uint256 borrowedAmount, bytes calldata data) external returns (bytes32);
}

/**
 * @title Project6_CallbackProtocol
 * @notice Mini-Project 6: Flashloan-style callback mechanism with reentrancy protection and balance delta verification.
 */
contract Project6_CallbackProtocol {
    error ReentrancyGuardReentrantCall();
    error InsufficientLiquidity();
    error CallbackFailed();
    error InvalidCallbackReturn();
    error InsufficientRepayment(uint256 expected, uint256 actual);

    event LoanExecuted(address indexed borrower, uint256 amount, uint256 fee);

    bytes32 public constant CALLBACK_SUCCESS = keccak256("Sage.Callback.Success");
    uint256 public constant FEE_BPS = 30; // 0.3%

    uint256 private _status; // 1 = unlocked, 2 = locked
    uint256 public totalReserve;

    modifier nonReentrant() {
        if (_status == 2) revert ReentrancyGuardReentrantCall();
        _status = 2;
        _;
        _status = 1;
    }

    constructor() payable {
        _status = 1;
        totalReserve = msg.value;
    }

    receive() external payable {
        totalReserve += msg.value;
    }

    function flashLoan(uint256 amount, bytes calldata data) external nonReentrant {
        uint256 balanceBefore = address(this).balance;
        if (amount > balanceBefore) revert InsufficientLiquidity();

        uint256 fee = (amount * FEE_BPS) / 10_000;

        // Transfer funds to caller
        (bool sendSuccess, ) = msg.sender.call{value: amount}("");
        if (!sendSuccess) revert CallbackFailed();

        // Invoke callback on borrower
        bytes32 callbackResult = IProtocolCallback(msg.sender).onCallback(amount, data);
        if (callbackResult != CALLBACK_SUCCESS) {
            revert InvalidCallbackReturn();
        }

        // Verify balance delta (Accounting Invariant: balanceAfter >= balanceBefore + fee)
        uint256 balanceAfter = address(this).balance;
        if (balanceAfter < balanceBefore + fee) {
            revert InsufficientRepayment(balanceBefore + fee, balanceAfter);
        }

        totalReserve = balanceAfter;
        emit LoanExecuted(msg.sender, amount, fee);
    }
}
