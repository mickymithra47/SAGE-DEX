// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../phase2/interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {SagePair} from "../../phase3/core/SagePair.sol";
import {ISageCallee} from "../../phase3/interfaces/ISageAMM.sol";

// ==========================================
// SCENARIO 1 & 2: INFLATION & DONATION ATTACKER
// ==========================================
contract LPInflationAttacker {
    using SafeTokenTransfer for IERC20;

    function attemptInflation(SagePair pair, IERC20 t0, IERC20 t1) external {
        // Deposit tiny 2000 wei
        t0.safeTransfer(address(pair), 2000);
        t1.safeTransfer(address(pair), 2000);
        pair.mint(address(this));

        // Donate 100 ether directly
        t0.safeTransfer(address(pair), 100 ether);
    }
}

// ==========================================
// SCENARIO 9 & 10: REENTRANT LP ATTACKER
// ==========================================
contract ReentrantLPAttacker is ISageCallee {
    SagePair public targetPair;
    bool public attacked;

    function attemptReentrantMint(SagePair pair) external {
        targetPair = pair;
        pair.swap(10, 0, address(this), abi.encode(true));
    }

    // Flash swap callback attempts to call pair.mint() or pair.burn() during swap lock
    function sageCall(address, uint256, uint256, bytes calldata) external override {
        if (!attacked) {
            attacked = true;
            // Must REVERT with SagePair.Locked()
            targetPair.mint(address(this));
        }
    }
}

// ==========================================
// SCENARIO 17: REPEATED ROUNDING ARBITRAGEUR
// ==========================================
contract RepeatedRoundingArbitrageur {
    using SafeTokenTransfer for IERC20;

    function depositAndWithdrawRepeatedly(
        SagePair pair,
        IERC20 t0,
        IERC20 t1,
        uint256 times
    ) external {
        for (uint256 i = 0; i < times; i++) {
            t0.safeTransfer(address(pair), 1 ether);
            t1.safeTransfer(address(pair), 1 ether);
            uint256 shares = pair.mint(address(this));

            pair.transfer(address(pair), shares);
            pair.burn(address(this));
        }
    }
}
