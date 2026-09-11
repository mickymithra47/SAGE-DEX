// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageOracleEngine} from "../../../src/phase5/core/SageOracleEngine.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {
    FlashLoanSpotPriceAttacker,
    DonationPriceDistortionAttacker,
    DecimalMismatchTester
} from "../../../src/phase5/attack_lab/Phase5AttackLab.sol";

contract OracleAttackLabTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    SageOracleEngine internal oracle;
    ERC20Token internal token0;
    ERC20Token internal token1;

    function setUp() public {
        factory = new SageFactory(address(this));
        oracle = new SageOracleEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 20_000 ether);
        pair.mint(address(this));

        vm.warp(1000);
        oracle.update(address(pair));
    }

    // ATTACK 1: SINGLE-BLOCK FLASH LOAN SPOT PRICE MANIPULATION RESISTANCE
    function test_OracleAttack1_SingleBlockManipulationResistance() public {
        // Advance 1 hour under normal conditions
        vm.warp(4600);

        FlashLoanSpotPriceAttacker attacker = new FlashLoanSpotPriceAttacker();
        (, uint256 twapBefore) = attacker.executeSpotDistortion(oracle, address(pair), address(token0));

        // Attacker performs massive instantaneous swap skewing spot price
        token0.transfer(address(pair), 50_000 ether);
        pair.swap(0, 15_000 ether, address(this), new bytes(0));

        // In the same block, TWAP consultation over 1 hour is unchanged because timeElapsed in current block = 0
        uint256 twapAfter = oracle.consult(address(pair), address(token0), 1 ether, 3600);
        assertApproxEqRel(twapAfter, twapBefore, 0.01e18);
    }

    // ATTACK 3: DIRECT DONATION PRICE DISTORTION RESISTANCE
    function test_OracleAttack3_DirectDonationResistance() public {
        DonationPriceDistortionAttacker attacker = new DonationPriceDistortionAttacker();

        // Attacker donates 50,000 token0 directly
        token0.transfer(address(pair), 50_000 ether);

        // Stored reserves isolate pricing until sync; spot price remains based on stored reserves
        uint256 spot = attacker.inspectDonationImpact(oracle, address(pair), address(token0));
        assertEq(spot, 2 ether); // 20,000 / 10,000 = 2.0
    }

    // ATTACK 8: TOKEN DECIMAL MISMATCH EXPLOITATION
    function test_Attack8_DecimalMismatchNormalization() public {
        DecimalMismatchTester tester = new DecimalMismatchTester();
        uint256 scaled = tester.verifyDecimalScaling(500_000_000, 6, 18);
        assertEq(scaled, 500_000_000 * 1e12);
    }
}
