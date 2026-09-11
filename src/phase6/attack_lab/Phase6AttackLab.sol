// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageRouter} from "../interfaces/ISageRouter.sol";

// ==========================================
// SCENARIO 6: REENTRANT TOKEN ATTACKER
// ==========================================
contract ReentrantTokenAttacker {
    ISageRouter public immutable router;

    constructor(ISageRouter _router) {
        router = _router;
    }

    // Attempts reentrant re-execution during token transfer callback
    function attack(address[] calldata path) external {
        router.swapExactTokensForTokens(100, 1, path, address(this), block.timestamp + 300);
    }
}

// ==========================================
// SCENARIO 8: REVERTING ETH RECIPIENT
// ==========================================
contract RevertingETHRecipient {
    // Rejects all incoming plain ETH transfers
    receive() external payable {
        revert("RejectETH");
    }

    function attemptSwapExactTokensForETH(
        ISageRouter router,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external {
        router.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), block.timestamp + 300);
    }
}

// ==========================================
// SCENARIO 7: FAKE PAIR CALLBACK IMPERSONATOR
// ==========================================
contract FakePairCallbackImpersonator {
    function tryImpersonatePair(address target, bytes calldata data) external returns (bool success) {
        (success, ) = target.call(data);
    }
}
