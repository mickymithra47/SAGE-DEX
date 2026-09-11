// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {
    ReentrantSwapAttacker,
    DonationAttacker,
    FirstLiquidityInflationExploiter
} from "../../../src/phase3/attack_lab/Phase3AttackLab.sol";

contract AttackLabTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal attacker = address(0x6666);

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(address(this));
    }

    // ATTACK 1: REENTRANCY VIA CALLBACK DEFENSE
    function test_Attack1_ReentrancyDefense() public {
        ReentrantSwapAttacker reentAttacker = new ReentrantSwapAttacker();
        token0.transfer(address(reentAttacker), 1000 ether);

        // Reentrant swap attempt must revert due to locked mutex
        vm.expectRevert(abi.encodeWithSelector(SagePair.Locked.selector));
        reentAttacker.attack(pair, 100 ether);
    }

    // ATTACK 2: DIRECT DONATION DEFENSE (SKIM & SYNC)
    function test_Attack2_DirectDonationDefense() public {
        DonationAttacker donator = new DonationAttacker();
        token0.transfer(address(donator), 1000 ether);

        // Attacker donates 1000 token0 directly
        donator.donateToPair(token0, address(pair), 1000 ether);

        // Physical balance is 11,000 ether, but stored reserve remains 10,000 ether
        assertEq(token0.balanceOf(address(pair)), 11_000 ether);
        (uint112 r0, , ) = pair.getReserves();
        assertEq(r0, 10_000 ether);

        // Protocol calls skim() to sweep excess donation safely to fee recipient
        pair.skim(address(0xFEE));
        assertEq(token0.balanceOf(address(0xFEE)), 1000 ether);
    }

    // ATTACK 20: FIRST-LIQUIDITY INFLATION DEFENSE
    function test_Attack20_FirstLiquidityInflationDefense() public {
        // Deploy fresh pair
        ERC20Token tA = new ERC20Token("Token A2", "TKNA2", 18, 1_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B2", "TKNB2", 18, 1_000_000 ether);
        SagePair freshPair = SagePair(factory.createPair(address(tA), address(tB)));

        ERC20Token tok0 = ERC20Token(freshPair.token0());
        ERC20Token tok1 = ERC20Token(freshPair.token1());

        FirstLiquidityInflationExploiter exploiter = new FirstLiquidityInflationExploiter();
        tok0.transfer(address(exploiter), 100_000 ether);
        tok1.transfer(address(exploiter), 100_000 ether);

        // Attacker mints with minimum liquidity: MINIMUM_LIQUIDITY (1000) is locked permanently to address(0)
        uint256 shares = exploiter.executeInflationAttack(freshPair, tok0, tok1, 2000, 10_000 ether);
        assertEq(shares, 1000);
        assertEq(freshPair.balanceOf(address(0)), 1000); // 1000 shares burned to zero address
    }
}
