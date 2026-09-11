// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageLPAccountingEngine} from "../../../src/phase4/core/SageLPAccountingEngine.sol";
import {ISageLPPosition} from "../../../src/phase4/interfaces/ISageLPPosition.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract LPAccountingEngineTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    SageLPAccountingEngine internal engine;
    ERC20Token internal token0;
    ERC20Token internal token1;

    address internal alice = address(0xAAAA);
    address internal bob = address(0xBBBB);

    function setUp() public {
        factory = new SageFactory(address(this));
        engine = new SageLPAccountingEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        // Alice funds initial liquidity (1000 token0 and 2000 token1)
        token0.transfer(address(pair), 1000 ether);
        token1.transfer(address(pair), 2000 ether);
        pair.mint(alice);

        token0.transfer(bob, 100_000 ether);
        token1.transfer(bob, 100_000 ether);
    }

    function test_Engine_GetPosition() public view {
        ISageLPPosition.PositionView memory pos = engine.getPosition(address(pair), alice);

        assertEq(pos.pair, address(pair));
        assertEq(pos.user, alice);
        assertGt(pos.userShares, 0);
        assertEq(pos.ownershipBps, 9999); // Almost 100% (minus 1000 dead shares)
        assertEq(pos.reserve0, 1000 ether);
        assertEq(pos.reserve1, 2000 ether);
    }

    function test_Engine_QuoteAddLiquidity() public view {
        // Bob wants to deposit 500 token0
        ISageLPPosition.DepositQuote memory quote = engine.quoteAddLiquidity(
            address(pair),
            500 ether,
            1500 ether // Bob provides up to 1500 token1
        );

        // Optimal ratio is 1:2 -> exactly 1000 token1 required
        assertEq(quote.amount0Optimal, 500 ether);
        assertEq(quote.amount1Optimal, 1000 ether);
        assertGt(quote.expectedLiquidityShares, 0);
        assertFalse(quote.isInitialDeposit);
    }

    function test_Engine_QuoteRemoveLiquidity() public {
        uint256 aliceShares = pair.balanceOf(alice);
        uint256 burnHalf = aliceShares / 2;

        ISageLPPosition.WithdrawalQuote memory quote = engine.quoteRemoveLiquidity(
            address(pair),
            alice,
            burnHalf
        );

        // Expect half of the reserves returned
        assertEq(quote.amount0, (burnHalf * 1000 ether) / pair.totalSupply());
        assertEq(quote.amount1, (burnHalf * 2000 ether) / pair.totalSupply());
        assertEq(quote.remainingUserShares, aliceShares - burnHalf);
    }
}
