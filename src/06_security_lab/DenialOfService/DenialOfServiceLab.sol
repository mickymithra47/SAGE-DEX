// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title VulnerableAuction
 * @notice Flawed auction using push payments to refund outbid bidders.
 */
contract VulnerableAuction {
    address public highestBidder;
    uint256 public highestBid;

    function bid() external payable {
        require(msg.value > highestBid, "Bid too low");

        address previousBidder = highestBidder;
        uint256 previousBid = highestBid;

        highestBidder = msg.sender;
        highestBid = msg.value;

        // VULNERABILITY: Push payment to untrusted previous bidder!
        // If previousBidder is a smart contract that reverts on receive,
        // no one can EVER outbid them! The auction is permanently DoS'd.
        if (previousBidder != address(0)) {
            (bool success, ) = payable(previousBidder).call{value: previousBid}("");
            require(success, "Refund failed");
        }
    }
}

/**
 * @title DosAttacker
 * @notice Attacker contract that bids and reverts on receiving ETH to permanently freeze the auction
 */
contract DosAttacker {
    VulnerableAuction public immutable target;

    constructor(address _target) {
        target = VulnerableAuction(_target);
    }

    function attack() external payable {
        target.bid{value: msg.value}();
    }

    // Reverts on any incoming ETH, freezing the VulnerableAuction
    receive() external payable {
        revert("DoS: refusing refunds!");
    }
}

/**
 * @title SecurePullAuction
 * @notice Hardened auction using the Pull-Over-Push payment pattern.
 */
contract SecurePullAuction {
    error BidTooLow();
    error NoRefundAvailable();
    error TransferFailed();

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public pendingRefunds;

    function bid() external payable {
        if (msg.value <= highestBid) revert BidTooLow();

        if (highestBidder != address(0)) {
            // Record refund internally instead of pushing ETH
            pendingRefunds[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawRefund() external {
        uint256 refund = pendingRefunds[msg.sender];
        if (refund == 0) revert NoRefundAvailable();

        pendingRefunds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: refund}("");
        if (!success) revert TransferFailed();
    }
}
