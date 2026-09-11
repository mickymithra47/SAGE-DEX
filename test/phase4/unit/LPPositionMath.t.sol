// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {LPPositionMath} from "../../../src/phase4/libraries/LPPositionMath.sol";

contract LPPositionMathTest is Test {
    // 1. Initial Liquidity Math with 1000 minimum liquidity lock
    function test_LPMath_InitialLiquidity() public pure {
        (uint256 userShares, uint256 lockedShares) = LPPositionMath.calculateInitialLiquidity(
            100 ether,
            400 ether,
            1000
        );
        // sqrt(100 * 400) * 1e18 = 200 ether
        assertEq(userShares, 200 ether - 1000);
        assertEq(lockedShares, 1000);
    }

    // 2. Additional Liquidity Proportional Minting
    function test_LPMath_AdditionalLiquidity() public pure {
        uint256 shares = LPPositionMath.calculateAdditionalLiquidity(
            50 ether,
            100 ether,
            1000 ether,
            2000 ether,
            500 ether
        );
        // (50 * 500) / 1000 = 25 ether
        assertEq(shares, 25 ether);
    }

    // 3. Redemption Asset Calculation
    function test_LPMath_RedemptionCalculation() public pure {
        (uint256 a0, uint256 a1) = LPPositionMath.calculateRedemption(
            50 ether,
            1000 ether,
            2000 ether,
            500 ether
        );
        // (50 * 1000) / 500 = 100 ether; (50 * 2000) / 500 = 200 ether
        assertEq(a0, 100 ether);
        assertEq(a1, 200 ether);
    }

    // 4. Ownership Basis Points
    function test_LPMath_OwnershipBps() public pure {
        uint256 bps = LPPositionMath.calculateOwnershipBps(250 ether, 1000 ether);
        assertEq(bps, 2500); // 25.00%
    }

    // 5. Impermanent Loss Basis Points
    function test_LPMath_ImpermanentLoss() public pure {
        // Price doubles: r = 2.0 (2e18)
        uint256 ilBps = LPPositionMath.calculateImpermanentLossBps(2e18);
        // Standard IL for 2x price shift is ~5.7% (571 bps)
        assertEq(ilBps, 571);
    }

    // 6. Total Position Valuation
    function test_LPMath_PositionValuation() public pure {
        // User owns 50% of pool with 10 ETH ($2000/ETH) and 20,000 USDC ($1/USDC)
        uint256 totalValWad = LPPositionMath.calculatePositionValue(
            500 ether,
            1000 ether,
            10 ether,
            20_000 ether,
            2000 ether,
            1 ether
        );
        // Total Pool Value = (10 * 2000) + (20,000 * 1) = $40,000. 50% claim = $20,000.
        assertEq(totalValWad, 20_000 ether);
    }
}
