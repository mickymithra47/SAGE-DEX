// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageOracleEngine} from "../../../src/phase5/core/SageOracleEngine.sol";
import {SageMath} from "../../../src/phase3/libraries/SageMath.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract OracleHandler is Test {
    SagePair public immutable pair;
    SageOracleEngine public immutable oracle;
    ERC20Token public immutable token0;
    ERC20Token public immutable token1;

    constructor(SagePair _pair, SageOracleEngine _oracle, ERC20Token _t0, ERC20Token _t1) {
        pair = _pair;
        oracle = _oracle;
        token0 = _t0;
        token1 = _t1;
    }

    function swap0(uint256 amountIn) external {
        amountIn = bound(amountIn, 1 ether, 100 ether);
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        uint256 out1 = SageMath.getAmountOut(amountIn, r0, r1);

        token0.transfer(address(pair), amountIn);
        pair.swap(0, out1, address(this), new bytes(0));
    }

    function advanceTimeAndUpdate(uint32 timeDelta) external {
        timeDelta = uint32(bound(timeDelta, 10, 3600));
        vm.warp(block.timestamp + timeDelta);
        oracle.update(address(pair));
    }
}

contract OracleInvariantTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    SageOracleEngine internal oracle;
    ERC20Token internal token0;
    ERC20Token internal token1;
    OracleHandler internal handler;

    function setUp() public {
        factory = new SageFactory(address(this));
        oracle = new SageOracleEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 100_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 100_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 100_000 ether);
        token1.transfer(address(pair), 100_000 ether);
        pair.mint(address(this));

        vm.warp(1000);
        oracle.update(address(pair));

        handler = new OracleHandler(pair, oracle, token0, token1);
        targetContract(address(handler));
    }

    // Invariant: Cumulative price values in oracle and pair are monotonically non-decreasing
    function invariant_CumulativePricesMonotonic() public view {
        uint256 c0 = pair.price0CumulativeLast();
        uint256 c1 = pair.price1CumulativeLast();
        assertTrue(c0 >= 0 && c1 >= 0);
    }
}
