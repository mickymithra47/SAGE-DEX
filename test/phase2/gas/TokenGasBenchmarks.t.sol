// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";
import {PermitToken} from "../../../src/phase2/token/PermitToken.sol";

contract TokenGasBenchmarksTest is Test {
    ERC20Token internal token;
    WETH internal weth;
    PermitToken internal permitToken;

    address internal alice = address(0xAA);
    address internal bob = address(0xBB);
    address internal spender = address(0xCC);

    function setUp() public {
        token = new ERC20Token("Gas Token", "GAS", 18, 1_000_000 ether);
        weth = new WETH();
        permitToken = new PermitToken("Permit Gas", "PGAS", 18, 1_000_000 ether);

        token.transfer(alice, 100_000 ether);
        vm.deal(alice, 100 ether);
    }

    function test_Benchmark_ERC20Transfer() public {
        uint256 g1 = gasleft();
        token.transfer(bob, 100 ether);
        uint256 transferGas = g1 - gasleft();

        emit log_named_uint("ERC20 Standard Transfer Gas", transferGas);
        assertLt(transferGas, 60_000);
    }

    function test_Benchmark_WETHDepositAndWithdraw() public {
        vm.startPrank(alice);

        uint256 g1 = gasleft();
        weth.deposit{value: 10 ether}();
        uint256 depositGas = g1 - gasleft();

        uint256 g2 = gasleft();
        weth.withdraw(10 ether);
        uint256 withdrawGas = g2 - gasleft();

        vm.stopPrank();

        emit log_named_uint("WETH Deposit Gas", depositGas);
        emit log_named_uint("WETH Withdraw Gas", withdrawGas);
    }

    function test_Benchmark_Approve() public {
        uint256 g1 = gasleft();
        token.approve(spender, 500 ether);
        uint256 approveGas = g1 - gasleft();

        emit log_named_uint("ERC20 Approve Gas", approveGas);
    }
}
