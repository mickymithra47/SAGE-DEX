// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../phase2/interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {SagePair} from "../../phase3/core/SagePair.sol";
import {SageFactory} from "../../phase3/core/SageFactory.sol";
import {LPPositionMath} from "../libraries/LPPositionMath.sol";
import {SageMath} from "../../phase3/libraries/SageMath.sol";

// ==========================================
// MINI PROJECT 1: LP MATH CALCULATOR
// ==========================================
contract Project1_LPMathCalculator {
    function computeOwnershipBps(uint256 userShares, uint256 totalShares) external pure returns (uint256) {
        return LPPositionMath.calculateOwnershipBps(userShares, totalShares);
    }

    function computeImpermanentLoss(uint256 priceRatioWad) external pure returns (uint256) {
        return LPPositionMath.calculateImpermanentLossBps(priceRatioWad);
    }
}

// ==========================================
// MINI PROJECT 2: INITIAL LIQUIDITY CALCULATOR
// ==========================================
contract Project2_InitialLiquidityCalculator {
    function computeInitialLP(uint256 a0, uint256 a1, uint256 minLiq) external pure returns (uint256 userShares, uint256 lockedShares) {
        return LPPositionMath.calculateInitialLiquidity(a0, a1, minLiq);
    }
}

// ==========================================
// MINI PROJECT 3: ADDITIONAL LIQUIDITY CALCULATOR
// ==========================================
contract Project3_AdditionalLiquidityCalculator {
    function computeAdditionalLP(uint256 a0, uint256 a1, uint256 r0, uint256 r1, uint256 total) external pure returns (uint256) {
        return LPPositionMath.calculateAdditionalLiquidity(a0, a1, r0, r1, total);
    }
}

// ==========================================
// MINI PROJECT 4: LIQUIDITY WITHDRAWAL CALCULATOR
// ==========================================
contract Project4_LiquidityWithdrawalCalculator {
    function computeRedemptionAssets(uint256 shares, uint256 r0, uint256 r1, uint256 total) external pure returns (uint256 a0, uint256 a1) {
        return LPPositionMath.calculateRedemption(shares, r0, r1, total);
    }
}

// ==========================================
// MINI PROJECT 5: LP SHARE ACCOUNTING LEDGER
// ==========================================
contract Project5_LPShareAccounting {
    mapping(address => uint256) public userShares;
    uint256 public totalShares;

    function recordMint(address user, uint256 amount) external {
        userShares[user] += amount;
        totalShares += amount;
    }

    function recordBurn(address user, uint256 amount) external {
        require(userShares[user] >= amount, "Insufficient");
        userShares[user] -= amount;
        totalShares -= amount;
    }
}

// ==========================================
// MINI PROJECT 6: TRANSFERABLE LP POSITION
// ==========================================
contract Project6_TransferableLPToken {
    using SafeTokenTransfer for IERC20;

    function transferPosition(SagePair pair, address to, uint256 shares) external {
        IERC20(address(pair)).safeTransferFrom(msg.sender, to, shares);
    }
}

// ==========================================
// MINI PROJECT 7: COMPLETE ADD/REMOVE LIQUIDITY
// ==========================================
contract Project7_CompleteAddRemoveLiquidity {
    using SafeTokenTransfer for IERC20;

    function addLiquidityDirect(SagePair pair, uint256 a0, uint256 a1, address to) external returns (uint256 shares) {
        IERC20(pair.token0()).safeTransferFrom(msg.sender, address(pair), a0);
        IERC20(pair.token1()).safeTransferFrom(msg.sender, address(pair), a1);
        shares = pair.mint(to);
    }

    function removeLiquidityDirect(SagePair pair, uint256 shares, address to) external returns (uint256 a0, uint256 a1) {
        IERC20(address(pair)).safeTransferFrom(msg.sender, address(pair), shares);
        (a0, a1) = pair.burn(to);
    }
}

// ==========================================
// MINI PROJECT 8: MULTI-LP SIMULATION
// ==========================================
contract Project8_MultiLPSimulation {
    struct LPAccount {
        address account;
        uint256 deposited0;
        uint256 deposited1;
        uint256 shares;
    }

    mapping(address => LPAccount) public accounts;

    function recordDeposit(address user, uint256 a0, uint256 a1, uint256 shares) external {
        accounts[user] = LPAccount(user, a0, a1, shares);
    }
}

// ==========================================
// MINI PROJECT 9: FEE ACCUMULATION SIMULATION
// ==========================================
contract Project9_FeeAccumulationSimulation {
    function computeValuePerShare(uint256 reserve0, uint256 reserve1, uint256 totalShares) external pure returns (uint256 r0PerShare, uint256 r1PerShare) {
        require(totalShares > 0, "Zero shares");
        r0PerShare = (reserve0 * 1e18) / totalShares;
        r1PerShare = (reserve1 * 1e18) / totalShares;
    }
}

// ==========================================
// MINI PROJECT 10: FIRST DEPOSITOR ATTACK LAB
// ==========================================
contract Project10_FirstDepositorAttackLab {
    function simulateInflationResistance(uint256 deposit0, uint256 deposit1) external pure returns (uint256 userShares, uint256 deadShares) {
        return LPPositionMath.calculateInitialLiquidity(deposit0, deposit1, 1000);
    }
}

// ==========================================
// MINI PROJECT 11: DONATION ROUNDING LAB
// ==========================================
contract Project11_DonationRoundingAttackLab {
    function computeDonationDilution(
        uint256 userShares,
        uint256 totalShares,
        uint256 reserveAfterDonation
    ) external pure returns (uint256 claimAfterDonation) {
        claimAfterDonation = (userShares * reserveAfterDonation) / totalShares;
    }
}

// ==========================================
// MINI PROJECT 12: STATEFUL LP INVARIANT AMM
// ==========================================
contract Project12_StatefulLPInvariantAMM {
    function verifyLPOwnershipConservation(
        uint256[] calldata shares,
        uint256 deadShares,
        uint256 totalSupply
    ) external pure returns (bool isValid) {
        uint256 sum = deadShares;
        for (uint256 i = 0; i < shares.length; i++) {
            sum += shares[i];
        }
        isValid = (sum == totalSupply);
    }
}
