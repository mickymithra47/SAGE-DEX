// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SageFactory} from "../../src/phase3/core/SageFactory.sol";
import {SagePair} from "../../src/phase3/core/SagePair.sol";
import {SageRouter} from "../../src/phase6/core/SageRouter.sol";
import {Permit2} from "../../src/phase7/core/Permit2.sol";
import {SagePermitRouter} from "../../src/phase7/core/SagePermitRouter.sol";
import {WETH} from "../../src/phase2/token/WETH.sol";
import {ERC20Token} from "../../src/phase2/token/ERC20Token.sol";
import {SageOracleEngine} from "../../src/phase5/core/SageOracleEngine.sol";
import {IPermit2} from "../../src/phase7/interfaces/IPermit2.sol";

contract Phase12EndToEndIntegrationTest is Test {
    SageFactory public factory;
    WETH public weth;
    SageRouter public router;
    Permit2 public permit2;
    SagePermitRouter public permitRouter;
    SageOracleEngine public oracle;

    ERC20Token public tokenA; // 18 decimals (aUSD)
    ERC20Token public tokenB; // 6 decimals (USDC)
    ERC20Token public tokenC; // 8 decimals (WBTC)

    SagePair public pairAB;
    SagePair public pairAC;

    address public alice;
    address public bob = address(0x2222);
    uint256 internal alicePk = 0xA11CE;

    function setUp() public {
        alice = vm.addr(alicePk);
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));
        permit2 = new Permit2();
        permitRouter = new SagePermitRouter(address(factory), address(weth), address(permit2));
        oracle = new SageOracleEngine();

        tokenA = new ERC20Token("Sage USD", "aUSD", 18, 100_000_000 ether);
        tokenB = new ERC20Token("USD Coin", "USDC", 6, 100_000_000 * 10**6);
        tokenC = new ERC20Token("Wrapped BTC", "WBTC", 8, 100_000 * 10**8);

        address pAB = factory.createPair(address(tokenA), address(tokenB));
        address pAC = factory.createPair(address(tokenA), address(tokenC));
        pairAB = SagePair(pAB);
        pairAC = SagePair(pAC);

        // Distribute funds to Alice and Bob
        tokenA.transfer(alice, 1_000_000 ether);
        tokenB.transfer(alice, 1_000_000 * 10**6);
        tokenC.transfer(alice, 100 * 10**8);

        tokenA.transfer(bob, 1_000_000 ether);
        tokenB.transfer(bob, 1_000_000 * 10**6);
        tokenC.transfer(bob, 100 * 10**8);

        // Seed initial liquidity: 100,000 aUSD (18 dec) + 100,000 USDC (6 dec)
        tokenA.transfer(address(pairAB), 100_000 ether);
        tokenB.transfer(address(pairAB), 100_000 * 10**6);
        pairAB.mint(address(this));

        // Seed initial liquidity: 600,000 aUSD (18 dec) + 10 WBTC (8 dec) -> 1 WBTC = 60,000 aUSD
        tokenA.transfer(address(pairAC), 600_000 ether);
        tokenC.transfer(address(pairAC), 10 * 10**8);
        pairAC.mint(address(this));
    }

    // --- TEST 1: Pool Discovery & Deterministic Ordering ---
    function test_E2E_01_CreatePool_Deterministic() public {
        ERC20Token tX = new ERC20Token("Token X", "TKX", 18, 1000 ether);
        ERC20Token tY = new ERC20Token("Token Y", "TKY", 18, 1000 ether);

        address p1 = factory.createPair(address(tX), address(tY));
        assertTrue(p1 != address(0), "Pool address must be non-zero");

        // Bi-directional lookup must resolve to the identical pair address
        assertEq(factory.getPair(address(tX), address(tY)), p1);
        assertEq(factory.getPair(address(tY), address(tX)), p1);
    }

    // --- TEST 2: Add Liquidity ---
    function test_E2E_02_AddLiquidity() public {
        vm.startPrank(alice);
        tokenA.transfer(address(pairAB), 10_000 ether);
        tokenB.transfer(address(pairAB), 10_000 * 10**6);
        uint256 shares = pairAB.mint(alice);
        vm.stopPrank();

        assertTrue(shares > 0, "Alice must receive non-zero LP shares");
        assertEq(pairAB.balanceOf(alice), shares);
    }

    // --- TEST 3: Swap Token A (18 dec) -> Token B (6 dec) ---
    function test_E2E_03_Swap_TokenA_to_TokenB() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint256 amountIn = 1000 ether; // 1,000 aUSD
        uint256 prevBalB = tokenB.balanceOf(alice);

        router.swapExactTokensForTokens(amountIn, 0, path, alice, block.timestamp);
        uint256 postBalB = tokenB.balanceOf(alice);

        uint256 receivedB = postBalB - prevBalB;
        assertTrue(receivedB > 0, "Alice must receive USDC output");
        assertTrue(receivedB >= 980 * 10**6 && receivedB <= 1000 * 10**6);
        vm.stopPrank();
    }

    // --- TEST 4: Swap Token B (6 dec) -> Token A (18 dec) ---
    function test_E2E_04_Swap_TokenB_to_TokenA() public {
        vm.startPrank(bob);
        tokenB.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenB);
        path[1] = address(tokenA);

        uint256 amountIn = 1000 * 10**6; // 1,000 USDC
        uint256 prevBalA = tokenA.balanceOf(bob);

        router.swapExactTokensForTokens(amountIn, 0, path, bob, block.timestamp);
        uint256 postBalA = tokenA.balanceOf(bob);

        uint256 receivedA = postBalA - prevBalA;
        assertTrue(receivedA > 0, "Bob must receive aUSD output");
        assertTrue(receivedA >= 980 ether && receivedA <= 1000 ether);
        vm.stopPrank();
    }

    // --- TEST 5: Swap Token A (18 dec) -> Token C (8 dec) ---
    function test_E2E_05_Swap_TokenA_to_TokenC() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenC);

        uint256 amountIn = 60_000 ether; // 60,000 aUSD (approx 1 WBTC)
        uint256 prevBalC = tokenC.balanceOf(alice);

        router.swapExactTokensForTokens(amountIn, 0, path, alice, block.timestamp);
        uint256 postBalC = tokenC.balanceOf(alice);

        uint256 receivedC = postBalC - prevBalC;
        assertTrue(receivedC > 0, "Alice must receive WBTC");
        assertTrue(receivedC >= 90_000_000 && receivedC <= 100_000_000);
        vm.stopPrank();
    }

    // --- TEST 6: Swap Token C (8 dec) -> Token A (18 dec) ---
    function test_E2E_06_Swap_TokenC_to_TokenA() public {
        vm.startPrank(bob);
        tokenC.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenC);
        path[1] = address(tokenA);

        uint256 amountIn = 1 * 10**8; // 1 WBTC
        uint256 prevBalA = tokenA.balanceOf(bob);

        router.swapExactTokensForTokens(amountIn, 0, path, bob, block.timestamp);
        uint256 postBalA = tokenA.balanceOf(bob);

        uint256 receivedA = postBalA - prevBalA;
        assertTrue(receivedA > 0, "Bob must receive aUSD output");
        assertTrue(receivedA >= 50_000 ether && receivedA <= 60_000 ether);
        vm.stopPrank();
    }

    // --- TEST 7: Remove Partial Liquidity ---
    function test_E2E_07_RemovePartialLiquidity() public {
        vm.startPrank(alice);
        tokenA.transfer(address(pairAB), 10_000 ether);
        tokenB.transfer(address(pairAB), 10_000 * 10**6);
        uint256 shares = pairAB.mint(alice);

        uint256 burnShares = shares / 2;
        pairAB.transfer(address(pairAB), burnShares);
        (uint256 amount0, uint256 amount1) = pairAB.burn(alice);

        assertTrue(amount0 > 0 && amount1 > 0, "Alice must receive redeemed underlying assets");
        assertEq(pairAB.balanceOf(alice), shares - burnShares);
        vm.stopPrank();
    }

    // --- TEST 8: Transfer LP Tokens to Bob ---
    function test_E2E_08_TransferLPTokens() public {
        vm.startPrank(alice);
        tokenA.transfer(address(pairAB), 5_000 ether);
        tokenB.transfer(address(pairAB), 5_000 * 10**6);
        uint256 shares = pairAB.mint(alice);

        pairAB.transfer(bob, shares);
        assertEq(pairAB.balanceOf(alice), 0);
        assertEq(pairAB.balanceOf(bob), shares);
        vm.stopPrank();
    }

    // --- TEST 9: Slippage Protection Enforcement ---
    function test_E2E_09_SlippageEnforcement() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Intentionally excessive amountOutMin must revert
        vm.expectRevert();
        router.swapExactTokensForTokens(1000 ether, 5000 * 10**6, path, alice, block.timestamp);
        vm.stopPrank();
    }

    // --- TEST 10: Deadline Protection Enforcement ---
    function test_E2E_10_DeadlineProtection() public {
        vm.startPrank(alice);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Expired deadline must revert
        vm.expectRevert();
        router.swapExactTokensForTokens(1000 ether, 0, path, alice, block.timestamp - 1);
        vm.stopPrank();
    }

    // --- TEST 11: Oracle TWAP Accumulator Updates ---
    function test_E2E_11_OracleTWAPAccumulation() public {
        uint256 p0CumBefore = pairAB.price0CumulativeLast();

        vm.warp(block.timestamp + 100);

        vm.startPrank(alice);
        tokenA.approve(address(router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        router.swapExactTokensForTokens(1000 ether, 0, path, alice, block.timestamp);
        vm.stopPrank();

        uint256 p0CumAfter = pairAB.price0CumulativeLast();
        assertTrue(p0CumAfter > p0CumBefore, "Cumulative price must increase over elapsed time");
    }
}
