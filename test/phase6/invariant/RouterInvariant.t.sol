// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../../src/phase6/core/SageRouter.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";

contract RouterHandler is Test {
    SageRouter public immutable router;
    ERC20Token public immutable tokenA;
    ERC20Token public immutable tokenB;
    SagePair public immutable pair;
    address public immutable trader;

    constructor(SageRouter _router, ERC20Token _tA, ERC20Token _tB, SagePair _pair, address _trader) {
        router = _router;
        tokenA = _tA;
        tokenB = _tB;
        pair = _pair;
        trader = _trader;
    }

    function swapAtoB(uint256 amountIn) external {
        amountIn = bound(amountIn, 1 ether, 100 ether);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        vm.prank(trader);
        router.swapExactTokensForTokens(amountIn, 1, path, trader, block.timestamp + 300);
    }

    function swapBtoA(uint256 amountIn) external {
        amountIn = bound(amountIn, 1 ether, 100 ether);
        address[] memory path = new address[](2);
        path[0] = address(tokenB);
        path[1] = address(tokenA);

        vm.prank(trader);
        router.swapExactTokensForTokens(amountIn, 1, path, trader, block.timestamp + 300);
    }
}

contract RouterInvariantTest is Test {
    SageFactory internal factory;
    SageRouter internal router;
    WETH internal weth;
    ERC20Token internal tokenA;
    ERC20Token internal tokenB;
    SagePair internal pair;
    RouterHandler internal handler;
    address internal trader = address(0x789);

    function setUp() public {
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        pair = SagePair(factory.createPair(address(tokenA), address(tokenB)));

        tokenA.transfer(address(pair), 500_000 ether);
        tokenB.transfer(address(pair), 500_000 ether);
        pair.mint(address(this));

        // Fund trader
        tokenA.transfer(trader, 10_000_000 ether);
        tokenB.transfer(trader, 10_000_000 ether);

        vm.startPrank(trader);
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);
        vm.stopPrank();

        handler = new RouterHandler(router, tokenA, tokenB, pair, trader);
        targetContract(address(handler));
    }

    // Invariant: Router balance for all tokens and ETH must ALWAYS remain 0
    function invariant_RouterZeroBalances() public view {
        assertEq(tokenA.balanceOf(address(router)), 0, "Router must not hold Token A");
        assertEq(tokenB.balanceOf(address(router)), 0, "Router must not hold Token B");
        assertEq(address(router).balance, 0, "Router must not hold ETH");
    }
}
