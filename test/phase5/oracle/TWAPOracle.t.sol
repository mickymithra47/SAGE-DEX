// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageOracleEngine} from "../../../src/phase5/core/SageOracleEngine.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract TWAPOracleTest is Test {
    SageFactory internal factory;
    SagePair internal pair;
    SageOracleEngine internal oracle;
    ERC20Token internal token0;
    ERC20Token internal token1;

    function setUp() public {
        factory = new SageFactory(address(this));
        oracle = new SageOracleEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        // Initial deposit: 100 token0 : 200 token1 (P0 = 2.0 token1 / token0)
        token0.transfer(address(pair), 100 ether);
        token1.transfer(address(pair), 200 ether);
        pair.mint(address(this));

        // Initial observation at t = 1000
        vm.warp(1000);
        oracle.update(address(pair));
    }

    function test_Oracle_TWAPCalculation() public {
        // Advance time by 3600 seconds (1 hour)
        vm.warp(4600);

        // Consult TWAP over 3600 seconds lookback
        uint256 amountOutTWAP = oracle.consult(address(pair), address(token0), 10 ether, 3600);

        // Expect 10 token0 * 2.0 = 20 token1
        assertApproxEqRel(amountOutTWAP, 20 ether, 0.01e18);
    }
}
