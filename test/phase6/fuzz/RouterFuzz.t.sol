// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterFuzzTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;
    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    SagePair internal pairAB;

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 1_000_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 1_000_000_000 ether);

        pairAB = SagePair(factory.createPair(address(tokenA), address(tokenB)));

        tokenA.transfer(address(pairAB), 1_000_000 ether);
        tokenB.transfer(address(pairAB), 1_000_000 ether);
        pairAB.mint(address(this));

        tokenA.approve(address(router), type(uint256).max);
    }

    // Fuzz Property: Exact-input swap output is strictly > 0 and router balance remains 0
    function testFuzz_Router_ExactInputSwapZeroResidual(uint256 amountIn) public {
        amountIn = bound(amountIn, 1 ether, 10_000 ether);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            1, // min 1 wei out
            path,
            address(this),
            block.timestamp + 300
        );

        assertTrue(amounts[1] > 0);
        assertEq(tokenA.balanceOf(address(router)), 0);
        assertEq(tokenB.balanceOf(address(router)), 0);
    }
}
