// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageQuoter} from "../../../src/phase5/core/SageQuoter.sol";
import {ISageQuoter} from "../../../src/phase5/interfaces/ISageQuoter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract QuoterTest is Test {
    SageFactory internal factory;
    SageQuoter internal quoter;
    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    ERC20Token internal tokenC;

    SagePair internal pairAB;
    SagePair internal pairBC;

    function setUp() public {
        factory = new SageFactory(address(this));
        quoter = new SageQuoter(address(factory));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);
        tokenC = new ERC20Token("Token C", "TKNC", 18, 10_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));
        pairBC = SagePair(factory.createPair(address(tokenB), address(tokenC)));

        // Seed Pool A/B: 1,000 A : 2,000 B
        tokenA.transfer(address(pairAB), 1_000 ether);
        tokenB.transfer(address(pairAB), 2_000 ether);
        pairAB.mint(address(this));

        // Seed Pool B/C: 2,000 B : 4,000 C
        tokenB.transfer(address(pairBC), 2_000 ether);
        tokenC.transfer(address(pairBC), 4_000 ether);
        pairBC.mint(address(this));
    }

    function test_Quoter_SingleHopExactInput() public view {
        ISageQuoter.QuoteResult memory q = quoter.quoteExactInputSingle(
            address(tokenA),
            address(tokenB),
            10 ether
        );

        assertTrue(q.amountOut > 0);
        assertEq(q.spotPriceWad, 2000 ether / 1000); // 2 WAD
        assertTrue(q.priceImpactBps > 0);
    }

    function test_Quoter_MultiHopExactInput() public view {
        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);

        (uint256[] memory amounts, uint256 impactBps) = quoter.quoteExactInputMultiHop(10 ether, path);

        assertEq(amounts.length, 3);
        assertEq(amounts[0], 10 ether);
        assertTrue(amounts[1] > 0);
        assertTrue(amounts[2] > 0);
        assertTrue(impactBps > 0);
    }

    function test_Quoter_SlippageBounds() public view {
        uint256 minOut = quoter.getMinimumOutputAmount(1000 ether, 50); // 0.50% slippage (50 bps)
        assertEq(minOut, 995 ether);

        uint256 maxIn = quoter.getMaximumInputAmount(1000 ether, 50);
        assertEq(maxIn, 1005 ether);
    }
}
