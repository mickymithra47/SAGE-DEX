// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {
    LPInflationAttacker,
    ReentrantLPAttacker,
    RepeatedRoundingArbitrageur
} from "../../../src/phase4/attack_lab/Phase4AttackLab.sol";

contract LPAttackLabTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal victim = address(0x9999);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(victim, 10_000 ether);
        token1.transfer(victim, 10_000 ether);
    }

    // ATTACK 1: FIRST DEPOSITOR INFLATION ATTACK RESISTANCE
    function test_LPAttack1_InflationAttackResistance() public {
        LPInflationAttacker attacker = new LPInflationAttacker();
        token0.transfer(address(attacker), 200 ether);
        token1.transfer(address(attacker), 200 ether);

        // Attacker mints tiny 2000 wei and donates 100 ether
        attacker.attemptInflation(pair, token0, token1);

        // Victim deposits 500 ether of both tokens
        vm.startPrank(victim);
        token0.transfer(address(pair), 500 ether);
        token1.transfer(address(pair), 500 ether);
        uint256 victimShares = pair.mint(victim);
        vm.stopPrank();

        // Victim receives valid non-zero LP shares (no 0-share rounding exploit)
        assertTrue(victimShares > 0);
    }

    // ATTACK 9 & 10: REENTRANCY DURING LIQUIDITY OPERATIONS
    function test_LPAttack9_ReentrancyDefense() public {
        // Seed initial pool liquidity
        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(address(this));

        ReentrantLPAttacker attacker = new ReentrantLPAttacker();
        token0.transfer(address(attacker), 100 ether);

        // Reentrant call during swap lock MUST revert with Locked()
        vm.expectRevert(abi.encodeWithSelector(SagePair.Locked.selector));
        attacker.attemptReentrantMint(pair);
    }

    // ATTACK 17: REPEATED DEPOSIT/WITHDRAW VALUE EXTRACTION DEFENSE
    function test_LPAttack17_RepeatedRoundingValueExtractionDefense() public {
        // Seed pool
        token0.transfer(address(pair), 100_000 ether);
        token1.transfer(address(pair), 100_000 ether);
        pair.mint(address(this));

        RepeatedRoundingArbitrageur arb = new RepeatedRoundingArbitrageur();
        token0.transfer(address(arb), 100 ether);
        token1.transfer(address(arb), 100 ether);

        uint256 arbBal0Before = token0.balanceOf(address(arb));
        uint256 arbBal1Before = token1.balanceOf(address(arb));

        // Attempt 20 rapid round-trip deposit and burns
        arb.depositAndWithdrawRepeatedly(pair, token0, token1, 20);

        uint256 arbBal0After = token0.balanceOf(address(arb));
        uint256 arbBal1After = token1.balanceOf(address(arb));

        // Arbitrageur cannot extract free value from rounding; net balances are <= initial balances
        assertLe(arbBal0After, arbBal0Before);
        assertLe(arbBal1After, arbBal1Before);
    }
}
