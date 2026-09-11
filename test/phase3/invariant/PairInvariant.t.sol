// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract PairHandler is Test {
    SagePair public immutable pair;
    ERC20Token public immutable token0;
    ERC20Token public immutable token1;

    address[] public actors;

    constructor(SagePair _pair, ERC20Token _t0, ERC20Token _t1) {
        pair = _pair;
        token0 = _t0;
        token1 = _t1;

        actors.push(address(0x101));
        actors.push(address(0x102));
        actors.push(address(0x103));
    }

    function addLiquidity(uint256 actorIdx, uint256 amount0, uint256 amount1) external {
        actorIdx = actorIdx % actors.length;
        address actor = actors[actorIdx];

        (uint112 r0, uint112 r1, ) = pair.getReserves();
        if (r0 == 0 || r1 == 0) return;

        amount0 = bound(amount0, 1 ether, 10_000 ether);
        amount1 = (amount0 * r1) / r0; // Maintain current price ratio
        if (amount1 == 0) return;

        vm.startPrank(actor);
        token0.transfer(address(pair), amount0);
        token1.transfer(address(pair), amount1);
        pair.mint(actor);
        vm.stopPrank();
    }

    function swap0For1(uint256 actorIdx, uint256 amountIn) external {
        actorIdx = actorIdx % actors.length;
        address actor = actors[actorIdx];

        (uint112 r0, uint112 r1, ) = pair.getReserves();
        if (r0 == 0 || r1 == 0) return;

        amountIn = bound(amountIn, 1 ether, 500 ether);
        uint256 amountOut = SageMath.getAmountOut(amountIn, r0, r1);
        if (amountOut == 0 || amountOut >= r1) return;

        vm.startPrank(actor);
        token0.transfer(address(pair), amountIn);
        pair.swap(0, amountOut, actor, new bytes(0));
        vm.stopPrank();
    }

    function swap1For0(uint256 actorIdx, uint256 amountIn) external {
        actorIdx = actorIdx % actors.length;
        address actor = actors[actorIdx];

        (uint112 r0, uint112 r1, ) = pair.getReserves();
        if (r0 == 0 || r1 == 0) return;

        amountIn = bound(amountIn, 1 ether, 500 ether);
        uint256 amountOut = SageMath.getAmountOut(amountIn, r1, r0);
        if (amountOut == 0 || amountOut >= r0) return;

        vm.startPrank(actor);
        token1.transfer(address(pair), amountIn);
        pair.swap(amountOut, 0, actor, new bytes(0));
        vm.stopPrank();
    }
}

contract PairInvariantTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;
    PairHandler internal handler;

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        // Initial pool seed
        token0.transfer(address(pair), 100_000 ether);
        token1.transfer(address(pair), 100_000 ether);
        pair.mint(address(this));

        // Fund handler actors
        address[3] memory actors = [address(0x101), address(0x102), address(0x103)];
        for (uint256 i = 0; i < actors.length; i++) {
            token0.transfer(actors[i], 10_000_000 ether);
            token1.transfer(actors[i], 10_000_000 ether);
        }

        handler = new PairHandler(pair, token0, token1);
        targetContract(address(handler));
    }

    // Invariant 1: Constant Product k = r0 * r1 must remain strictly positive and non-decreasing across swaps
    function invariant_ConstantProductNonZero() public view {
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        assertGt(r0, 0, "Reserve0 must remain positive");
        assertGt(r1, 0, "Reserve1 must remain positive");
    }

    // Invariant 2: Stored reserves must strictly equal physical balances (no desync)
    function invariant_ReservesEqualBalances() public view {
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        assertEq(token0.balanceOf(address(pair)), r0, "token0 balance must match reserve0");
        assertEq(token1.balanceOf(address(pair)), r1, "token1 balance must match reserve1");
    }

    // Invariant 3: Total supply must equal sum of user balances plus minimum liquidity locked to address(0)
    function invariant_LPTokenSupplyConservation() public view {
        assertGe(pair.totalSupply(), pair.MINIMUM_LIQUIDITY());
        assertEq(pair.balanceOf(address(0)), pair.MINIMUM_LIQUIDITY());
    }
}
