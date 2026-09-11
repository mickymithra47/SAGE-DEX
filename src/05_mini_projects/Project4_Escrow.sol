// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Project4_Escrow
 * @notice Mini-Project 4: Escrow contract with explicit state machine and role-based settlement.
 */
contract Project4_Escrow {
    enum EscrowState { Created, Funded, Disputed, Settled, Refunded }

    error InvalidState(EscrowState current, EscrowState expected);
    error Unauthorized();
    error TransferFailed();
    error ZeroDeposit();
    error TimelockActive(uint256 currentTime, uint256 releaseTime);

    event EscrowFunded(address indexed buyer, uint256 amount);
    event EscrowDisputed(address indexed disputer);
    event EscrowSettled(address indexed seller, uint256 amount);
    event EscrowRefunded(address indexed buyer, uint256 amount);

    address public immutable buyer;
    address public immutable seller;
    address public immutable arbiter;
    uint256 public immutable releaseTime;

    uint256 public depositAmount;
    EscrowState public state;

    modifier onlyBuyer() {
        if (msg.sender != buyer) revert Unauthorized();
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller) revert Unauthorized();
        _;
    }

    modifier onlyArbiter() {
        if (msg.sender != arbiter) revert Unauthorized();
        _;
    }

    modifier inState(EscrowState expected) {
        if (state != expected) revert InvalidState(state, expected);
        _;
    }

    constructor(address _seller, address _arbiter, uint256 _duration) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        releaseTime = block.timestamp + _duration;
        state = EscrowState.Created;
    }

    function fund() external payable onlyBuyer inState(EscrowState.Created) {
        if (msg.value == 0) revert ZeroDeposit();
        depositAmount = msg.value;
        state = EscrowState.Funded;

        emit EscrowFunded(msg.sender, msg.value);
    }

    function releaseToSeller() external onlyBuyer inState(EscrowState.Funded) {
        state = EscrowState.Settled;
        (bool success, ) = seller.call{value: depositAmount}("");
        if (!success) revert TransferFailed();

        emit EscrowSettled(seller, depositAmount);
    }

    function autoReleaseAfterTimelock() external onlySeller inState(EscrowState.Funded) {
        if (block.timestamp < releaseTime) {
            revert TimelockActive(block.timestamp, releaseTime);
        }

        state = EscrowState.Settled;
        (bool success, ) = seller.call{value: depositAmount}("");
        if (!success) revert TransferFailed();

        emit EscrowSettled(seller, depositAmount);
    }

    function raiseDispute() external inState(EscrowState.Funded) {
        if (msg.sender != buyer && msg.sender != seller) revert Unauthorized();
        state = EscrowState.Disputed;

        emit EscrowDisputed(msg.sender);
    }

    function resolveDispute(bool sendToSeller) external onlyArbiter inState(EscrowState.Disputed) {
        if (sendToSeller) {
            state = EscrowState.Settled;
            (bool success, ) = seller.call{value: depositAmount}("");
            if (!success) revert TransferFailed();
            emit EscrowSettled(seller, depositAmount);
        } else {
            state = EscrowState.Refunded;
            (bool success, ) = buyer.call{value: depositAmount}("");
            if (!success) revert TransferFailed();
            emit EscrowRefunded(buyer, depositAmount);
        }
    }
}
