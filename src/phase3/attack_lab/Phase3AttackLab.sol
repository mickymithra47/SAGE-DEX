// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../phase2/interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {SagePair} from "../core/SagePair.sol";
import {SageFactory} from "../core/SageFactory.sol";
import {ISageCallee} from "../interfaces/ISageAMM.sol";

// ==========================================
// SCENARIO 1: REENTRANCY ATTACKER
// ==========================================
contract ReentrantSwapAttacker is ISageCallee {
    SagePair public targetPair;
    bool public attacked;

    function attack(SagePair pair, uint256 amount0Out) external {
        targetPair = pair;
        pair.swap(amount0Out, 0, address(this), abi.encode(true));
    }

    // Reentrancy callback attempts to re-enter swap() while mutex is active
    function sageCall(address, uint256, uint256, bytes calldata) external override {
        if (!attacked) {
            attacked = true;
            // Attempt reentrancy -> MUST REVERT with SagePair.Locked()
            targetPair.swap(10, 0, address(this), new bytes(0));
        }
    }
}

// ==========================================
// SCENARIO 2: DIRECT DONATION ATTACKER
// ==========================================
contract DonationAttacker {
    using SafeTokenTransfer for IERC20;

    function donateToPair(IERC20 token, address pair, uint256 amount) external {
        token.safeTransfer(pair, amount);
    }
}

// ==========================================
// SCENARIO 3: FLASH SWAP BORROWER & ARBITRAGEUR
// ==========================================
contract FlashSwapArbitrageur is ISageCallee {
    using SafeTokenTransfer for IERC20;

    bool public flashSwapExecuted;

    function executeFlashBorrow(SagePair pair, uint256 amount0Out, address token0) external {
        bytes memory data = abi.encode(token0);
        pair.swap(amount0Out, 0, address(this), data);
    }

    function sageCall(address, uint256 amount0, uint256, bytes calldata data) external override {
        flashSwapExecuted = true;
        address token0 = abi.decode(data, (address));
        // Calculate fee with 0.3% fee: amount0 * 1000 / 997 + 1
        uint256 fee = ((amount0 * 3) / 997) + 1;
        uint256 amountToRepay = amount0 + fee;

        // Repay loan + fee back to Pair
        IERC20(token0).safeTransfer(msg.sender, amountToRepay);
    }
}

// ==========================================
// SCENARIO 20: FIRST-LIQUIDITY INFLATION EXPLOITER
// ==========================================
contract FirstLiquidityInflationExploiter {
    using SafeTokenTransfer for IERC20;

    function executeInflationAttack(
        SagePair pair,
        IERC20 token0,
        IERC20 token1,
        uint256 tinyAmount,
        uint256 hugeDonation
    ) external returns (uint256 mintedShares) {
        // Step 1: Deposit tiny amounts
        token0.safeTransfer(address(pair), tinyAmount);
        token1.safeTransfer(address(pair), tinyAmount);
        mintedShares = pair.mint(address(this));

        // Step 2: Donate huge token amounts directly to inflate share price
        token0.safeTransfer(address(pair), hugeDonation);
    }
}
