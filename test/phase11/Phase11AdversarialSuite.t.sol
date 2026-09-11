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
import {ReentrantSwapAttacker, DonationAttacker} from "../../src/phase3/attack_lab/Phase3AttackLab.sol";
import {IPermit2} from "../../src/phase7/interfaces/IPermit2.sol";

contract Phase11AdversarialSuiteTest is Test {
    SageFactory public factory;
    WETH public weth;
    SageRouter public router;
    Permit2 public permit2;
    SagePermitRouter public permitRouter;

    ERC20Token public tokenA;
    ERC20Token public tokenB;
    SagePair public pair;

    address public alice;
    address public attacker = address(0x9999);
    uint256 internal alicePk = 0xA11CE;

    function setUp() public {
        alice = vm.addr(alicePk);
        factory = new SageFactory(address(this));
        weth = new WETH();
        router = new SageRouter(address(factory), address(weth));
        permit2 = new Permit2();
        permitRouter = new SagePermitRouter(address(factory), address(weth), address(permit2));

        tokenA = new ERC20Token("Token A", "TKNA", 18, 10_000_000 ether);
        tokenB = new ERC20Token("Token B", "TKNB", 18, 10_000_000 ether);

        address pairAddr = factory.createPair(address(tokenA), address(tokenB));
        pair = SagePair(pairAddr);

        tokenA.transfer(alice, 1_000_000 ether);
        tokenB.transfer(alice, 1_000_000 ether);
        tokenA.transfer(attacker, 1_000_000 ether);
        tokenB.transfer(attacker, 1_000_000 ether);

        // Seed initial pool liquidity
        tokenA.transfer(address(pair), 100_000 ether);
        tokenB.transfer(address(pair), 100_000 ether);
        pair.mint(alice);
    }

    // --- 1. AMM Invariant & Flash Swap Reentrancy ---

    function test_Attack_AMM_Invariant_ZeroInput() public {
        vm.startPrank(attacker);
        tokenA.transfer(address(pair), 0);
        // Attempting to extract output with zero input must revert
        vm.expectRevert();
        pair.swap(0, 1000 ether, attacker, "");
        vm.stopPrank();
    }

    function test_Attack_FlashSwap_Reentrancy() public {
        ReentrantSwapAttacker reentAttacker = new ReentrantSwapAttacker();
        tokenA.transfer(address(reentAttacker), 10 ether);

        // Flash swap callback attempting to call pair.swap() must revert with Locked mutex
        vm.expectRevert(SagePair.Locked.selector);
        reentAttacker.attack(pair, 10 ether);
    }

    // --- 2. First-Liquidity Inflation Resistance ---

    function test_Attack_FirstLiquidity_Inflation() public {
        ERC20Token t0 = new ERC20Token("T0", "T0", 18, 1_000_000 ether);
        ERC20Token t1 = new ERC20Token("T1", "T1", 18, 1_000_000 ether);
        address pAddr = factory.createPair(address(t0), address(t1));
        SagePair p = SagePair(pAddr);

        t0.transfer(attacker, 10_000 ether);
        t1.transfer(attacker, 10_000 ether);

        vm.startPrank(attacker);
        t0.transfer(address(p), 2000);
        t1.transfer(address(p), 2000);
        // Initial mint locks MINIMUM_LIQUIDITY (1000) to address(0) and mints 1000 to attacker
        p.mint(attacker);

        assertEq(p.balanceOf(address(0)), 1000, "MINIMUM_LIQUIDITY must be locked to address(0)");
        assertEq(p.balanceOf(attacker), 1000, "Attacker receives 1000 initial shares");

        // Attacker attempts large donation to inflate share price
        t0.transfer(address(p), 1000 ether);
        t1.transfer(address(p), 1000 ether);
        p.sync();
        vm.stopPrank();

        // Victim deposits normal liquidity
        address victim = address(0x5555);
        t0.transfer(victim, 10 ether);
        t1.transfer(victim, 10 ether);

        vm.startPrank(victim);
        t0.transfer(address(p), 10 ether);
        t1.transfer(address(p), 10 ether);
        uint256 victimShares = p.mint(victim);
        vm.stopPrank();

        // Victim still receives proportional shares and is not completely diluted to 0
        assertTrue(victimShares > 0, "Victim must receive non-zero shares despite donation");
    }

    // --- 3. Direct Donation Defense & Sync ---

    function test_Attack_DirectDonationDefense() public {
        DonationAttacker donator = new DonationAttacker();
        tokenA.transfer(address(donator), 1000 ether);

        donator.donateToPair(tokenA, address(pair), 1000 ether);
        (uint112 r0, uint112 r1, ) = pair.getReserves();

        // Physical balance is higher, but tracked reserves remain unchanged until sync/skim
        if (address(tokenA) == pair.token0()) {
            assertTrue(tokenA.balanceOf(address(pair)) > r0);
        } else {
            assertTrue(tokenA.balanceOf(address(pair)) > r1);
        }

        pair.sync();
        (uint112 newR0, uint112 newR1, ) = pair.getReserves();
        if (address(tokenA) == pair.token0()) {
            assertEq(newR0, tokenA.balanceOf(address(pair)));
        } else {
            assertEq(newR1, tokenA.balanceOf(address(pair)));
        }
    }

    // --- 4. Router Slippage & Deadline Enforcement ---

    function test_Attack_Router_SlippageBypass() public {
        vm.startPrank(attacker);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Expecting 2,000 output when real pool output is ~990 must revert
        vm.expectRevert();
        router.swapExactTokensForTokens(1000 ether, 2000 ether, path, attacker, block.timestamp);
        vm.stopPrank();
    }

    function test_Attack_Router_ExpiredDeadline() public {
        vm.startPrank(attacker);
        tokenA.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        // Executing with deadline in the past must revert
        vm.expectRevert();
        router.swapExactTokensForTokens(100 ether, 0, path, attacker, block.timestamp - 1);
        vm.stopPrank();
    }

    // --- 5. Permit2 Signature Security & Replay Prevention ---

    function test_Attack_Permit2_SignatureReplay() public {
        vm.startPrank(alice);
        tokenA.approve(address(permit2), type(uint256).max);
        vm.stopPrank();

        IPermit2.TokenPermissions memory permitted = IPermit2.TokenPermissions({
            token: address(tokenA),
            amount: 100 ether
        });

        IPermit2.SignatureTransferDetails memory transferDetails = IPermit2.SignatureTransferDetails({
            to: attacker,
            requestedAmount: 100 ether
        });

        uint256 nonce = 42;
        uint256 deadline = block.timestamp + 1 hours;

        bytes32 typehash = keccak256("PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)");
        bytes32 tokenPermHash = keccak256(abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), address(tokenA), 100 ether));
        bytes32 structHash = keccak256(abi.encode(typehash, tokenPermHash, address(this), nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permit2.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        // First transfer executes successfully
        permit2.permitTransferFrom(
            IPermit2.PermitTransferFrom({permitted: permitted, nonce: nonce, deadline: deadline}),
            transferDetails,
            alice,
            sig
        );
        assertEq(tokenA.balanceOf(attacker), 1_000_100 ether);

        // Replay attempt with same nonce must revert
        vm.expectRevert();
        permit2.permitTransferFrom(
            IPermit2.PermitTransferFrom({permitted: permitted, nonce: nonce, deadline: deadline}),
            transferDetails,
            alice,
            sig
        );
    }
}
