// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract LPHandler is Test {
    SagePair public immutable pair;
    ERC20Token public immutable token0;
    ERC20Token public immutable token1;

    address[] public actors;

    constructor(SagePair _pair, ERC20Token _t0, ERC20Token _t1) {
        pair = _pair;
        token0 = _t0;
        token1 = _t1;

        actors.push(address(0x201));
        actors.push(address(0x202));
        actors.push(address(0x203));
    }

    function deposit(uint256 actorIdx, uint256 amount0, uint256 amount1) external {
        actorIdx = actorIdx % actors.length;
        address actor = actors[actorIdx];

        (uint112 r0, uint112 r1, ) = pair.getReserves();
        if (r0 == 0 || r1 == 0) return;

        amount0 = bound(amount0, 1 ether, 5_000 ether);
        amount1 = (amount0 * r1) / r0;
        if (amount1 == 0) return;

        vm.startPrank(actor);
        token0.transfer(address(pair), amount0);
        token1.transfer(address(pair), amount1);
        pair.mint(actor);
        vm.stopPrank();
    }

    function burn(uint256 actorIdx, uint256 burnFraction) external {
        actorIdx = actorIdx % actors.length;
        address actor = actors[actorIdx];

        uint256 bal = pair.balanceOf(actor);
        if (bal == 0) return;

        burnFraction = bound(burnFraction, 1, 100);
        uint256 sharesToBurn = (bal * burnFraction) / 100;
        if (sharesToBurn == 0) return;

        vm.startPrank(actor);
        pair.transfer(address(pair), sharesToBurn);
        pair.burn(actor);
        vm.stopPrank();
    }

    function transferShares(uint256 fromIdx, uint256 toIdx, uint256 fraction) external {
        fromIdx = fromIdx % actors.length;
        toIdx = toIdx % actors.length;
        if (fromIdx == toIdx) return;

        address from = actors[fromIdx];
        address to = actors[toIdx];

        uint256 bal = pair.balanceOf(from);
        if (bal == 0) return;

        fraction = bound(fraction, 1, 50);
        uint256 amount = (bal * fraction) / 100;
        if (amount == 0) return;

        vm.prank(from);
        pair.transfer(to, amount);
    }
}

contract LPInvariantTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    ERC20Token internal token0;
    ERC20Token internal token1;
    LPHandler internal handler;

    function setUp() public {
        factory = new SageFactory(address(this));
        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        // Seed initial pool
        token0.transfer(address(pair), 50_000 ether);
        token1.transfer(address(pair), 50_000 ether);
        pair.mint(address(this));

        // Fund actors
        address[3] memory actors = [address(0x201), address(0x202), address(0x203)];
        for (uint256 i = 0; i < actors.length; i++) {
            token0.transfer(actors[i], 10_000_000 ether);
            token1.transfer(actors[i], 10_000_000 ether);
        }

        handler = new LPHandler(pair, token0, token1);
        targetContract(address(handler));
    }

    // Invariant 1: Total supply of LP tokens strictly equals the sum of actor balances + locked minimum liquidity
    function invariant_LPSupplyConservation() public view {
        uint256 actorSum = pair.balanceOf(address(this)) +
            pair.balanceOf(address(0x201)) +
            pair.balanceOf(address(0x202)) +
            pair.balanceOf(address(0x203)) +
            pair.balanceOf(address(0)); // 1000 locked to 0x0

        assertEq(actorSum, pair.totalSupply(), "Total LP shares must strictly equal sum of all holder balances");
    }

    // Invariant 2: Stored reserves match actual token balances
    function invariant_LPReservesSolvency() public view {
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        assertEq(token0.balanceOf(address(pair)), r0, "Token0 balance must equal reserve0");
        assertEq(token1.balanceOf(address(pair)), r1, "Token1 balance must equal reserve1");
    }
}
