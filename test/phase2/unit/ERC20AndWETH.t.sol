// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {WETH} from "../../../src/phase2/token/WETH.sol";
import {DecimalsToken, TokenRegistry} from "../../../src/phase2/token/TokenRegistry.sol";

contract ERC20AndWETHTest is Test {
    ERC20Token internal token;
    WETH internal weth;
    DecimalsToken internal usdcToken;
    TokenRegistry internal registry;

    address internal alice = address(0xAA);
    address internal bob = address(0xBB);

    function setUp() public {
        token = new ERC20Token("Sage Token", "AKT", 18, 1_000_000 ether);
        weth = new WETH();
        usdcToken = new DecimalsToken("USD Coin", "USDC", 6, 1_000_000 * 1e6);
        registry = new TokenRegistry();

        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    // --- ERC-20 TESTS ---
    function test_ERC20_TransfersAndBalances() public {
        token.transfer(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.balanceOf(address(this)), 999_000 ether);

        vm.prank(alice);
        token.transfer(bob, 400 ether);
        assertEq(token.balanceOf(bob), 400 ether);
        assertEq(token.balanceOf(alice), 600 ether);
    }

    function test_ERC20_AllowancesAndTransferFrom() public {
        token.transfer(alice, 1000 ether);

        vm.prank(alice);
        token.approve(address(this), 500 ether);
        assertEq(token.allowance(alice, address(this)), 500 ether);

        token.transferFrom(alice, bob, 200 ether);
        assertEq(token.balanceOf(bob), 200 ether);
        assertEq(token.allowance(alice, address(this)), 300 ether);
    }

    function test_ERC20_RevertsOnInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20Token.InsufficientBalance.selector, alice, 0, 10 ether)
        );
        token.transfer(bob, 10 ether);
    }

    function test_ERC20_MintAndBurn() public {
        token.mint(alice, 500 ether);
        assertEq(token.balanceOf(alice), 500 ether);
        assertEq(token.totalSupply(), 1_000_500 ether);

        vm.prank(alice);
        token.burn(200 ether);
        assertEq(token.balanceOf(alice), 300 ether);
        assertEq(token.totalSupply(), 1_000_300 ether);
    }

    // --- WETH TESTS ---
    function test_WETH_DepositAndWithdraw() public {
        vm.startPrank(alice);
        weth.deposit{value: 5 ether}();
        assertEq(weth.balanceOf(alice), 5 ether);
        assertEq(address(weth).balance, 5 ether);
        assertEq(weth.totalSupply(), 5 ether);

        // Partial withdrawal
        weth.withdraw(2 ether);
        assertEq(weth.balanceOf(alice), 3 ether);
        assertEq(address(weth).balance, 3 ether);
        assertEq(alice.balance, 97 ether);

        // Receive fallback deposit
        (bool ok, ) = address(weth).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(weth.balanceOf(alice), 4 ether);
        vm.stopPrank();
    }

    // --- TOKEN REGISTRY TESTS ---
    function test_TokenRegistry_RegistrationAndClassification() public {
        registry.registerToken(
            address(token),
            TokenRegistry.TokenCategory.CategoryA_Standard,
            true
        );

        (
            address addr,
            string memory name,
            string memory symbol,
            uint8 dec,
            TokenRegistry.TokenCategory cat,
            bool verified,

        ) = registry.tokens(address(token));

        assertEq(addr, address(token));
        assertEq(name, "Sage Token");
        assertEq(symbol, "AKT");
        assertEq(dec, 18);
        assertEq(uint8(cat), uint8(TokenRegistry.TokenCategory.CategoryA_Standard));
        assertTrue(verified);
        assertEq(registry.getTokenCount(), 1);
    }
}
