// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../../src/phase3/core/SagePair.sol";
import {SageQuoter} from "../../../src/phase5/core/SageQuoter.sol";
import {SageOracleEngine} from "../../../src/phase5/core/SageOracleEngine.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";

contract PricingGasBenchmarksTest is Test {
    SageFactory internal factory;
    SageQuoter internal quoter;
    SageOracleEngine internal oracle;
    ERC20Token internal token0;
    ERC20Token internal token1;
    SagePair internal pair;

    function setUp() public {
        factory = new SageFactory(address(this));
        quoter = new SageQuoter(address(factory));
        oracle = new SageOracleEngine();

        ERC20Token tA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        ERC20Token tB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddress = factory.createPair(address(tA), address(tB));
        pair = SagePair(pairAddress);

        token0 = ERC20Token(pair.token0());
        token1 = ERC20Token(pair.token1());

        token0.transfer(address(pair), 10_000 ether);
        token1.transfer(address(pair), 10_000 ether);
        pair.mint(address(this));

        vm.warp(1000);
        oracle.update(address(pair));
    }

    function test_Benchmark_QuoterExactInputSingle() public view {
        quoter.quoteExactInputSingle(address(token0), address(token1), 10 ether);
    }

    function test_Benchmark_OracleConsult() public {
        vm.warp(4600);
        oracle.consult(address(pair), address(token0), 10 ether, 3600);
    }
}
