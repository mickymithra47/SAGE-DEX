// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterGasBenchmarksTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;
    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    ERC20Token internal tokenC;
    SagePair internal pairAB;
    SagePair internal pairBC;

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);
        tokenC = new ERC20Token("Token C", "TKNC", 18, 10_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));
        pairBC = SagePair(factory.createPair(address(tokenB), address(tokenC)));

        tokenA.transfer(address(pairAB), 100_000 ether);
        tokenB.transfer(address(pairAB), 100_000 ether);
        pairAB.mint(address(this));

        tokenB.transfer(address(pairBC), 100_000 ether);
        tokenC.transfer(address(pairBC), 100_000 ether);
        pairBC.mint(address(this));

        tokenA.approve(address(router), type(uint256).max);
    }

    function test_Benchmark_SingleHopExactInput() public {
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        router.swapExactTokensForTokens(10 ether, 1, path, address(this), block.timestamp + 300);
    }

    function test_Benchmark_TwoHopExactInput() public {
        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);

        router.swapExactTokensForTokens(10 ether, 1, path, address(this), block.timestamp + 300);
    }
}
