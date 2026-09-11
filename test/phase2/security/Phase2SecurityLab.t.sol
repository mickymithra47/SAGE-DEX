// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "../../../src/phase2/interfaces/IERC20.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {
    VulnerableAllowanceConsumer,
    SecureAllowanceConsumer,
    VulnerableApprovalToken,
    SecureApprovalHandler,
    VulnerableTransferHandler,
    SecureTransferHandler,
    VulnerableFalseReturnRecipient,
    SecureFalseReturnRecipient,
    VulnerableNoReturnConsumer,
    SecureNoReturnConsumer,
    VulnerableVaultReentrancy,
    SecureVaultReentrancy,
    VulnerableFeeOnTransferVault,
    SecureFeeOnTransferVault,
    VulnerableRebasingVault,
    SecureRebasingShareVault,
    VulnerableMultiDecimalSwap,
    SecureMultiDecimalSwap,
    VulnerablePermitNoContractAddress,
    SecurePermitWithDomainSeparator,
    VulnerableStaticDomainPermit,
    SecureDynamicDomainPermit,
    VulnerableNonceReusePermit,
    SecureNonceTrackingPermit
} from "../../../src/phase2/security_lab/Phase2SecurityLab.sol";
import {
    MockFalseReturnToken,
    MockNoReturnToken,
    MockFeeOnTransferToken,
    MockRebasingToken,
    MockReentrantToken
} from "../../../src/phase2/mocks/AdversarialTokens.sol";

contract Phase2SecurityLabTest is Test {
    // --- LAB 1: ALLOWANCE MISUSE ---
    function test_SecurityLab1_AllowanceMisuse() public {
        ERC20Token token = new ERC20Token("Token", "TKN", 18, 1_000_000 ether);
        SecureAllowanceConsumer secure = new SecureAllowanceConsumer();

        address victim = address(0x111);
        token.transfer(victim, 1000 ether);

        // Victim approves only 100 ether
        vm.prank(victim);
        token.approve(address(secure), 100 ether);

        // Attacker attempts to deposit 500 ether on victim's behalf -> REVERTS
        vm.expectRevert();
        secure.deposit(IERC20(address(token)), victim, 500 ether);
    }

    // --- LAB 2: APPROVAL RACE CONDITION ---
    function test_SecurityLab2_ApprovalRaceMitigation() public {
        ERC20Token token = new ERC20Token("Token", "TKN", 18, 1_000_000 ether);
        SecureApprovalHandler handler = new SecureApprovalHandler();

        address spender = address(0x222);
        token.transfer(address(handler), 1000 ether);

        // Sets allowance to 100, then resets safely to 50
        handler.safeApproveWithReset(IERC20(address(token)), spender, 100 ether);
        assertEq(token.allowance(address(handler), spender), 100 ether);

        handler.safeApproveWithReset(IERC20(address(token)), spender, 50 ether);
        assertEq(token.allowance(address(handler), spender), 50 ether);
    }

    // --- LAB 3 & 4: FALSE RETURN TOKEN ---
    function test_SecurityLab3_FalseReturnTokenHandling() public {
        MockFalseReturnToken falseToken = new MockFalseReturnToken(1000 ether);
        SecureFalseReturnRecipient secure = new SecureFalseReturnRecipient();

        address poorUser = address(0x999); // 0 balance

        vm.startPrank(poorUser);
        falseToken.approve(address(secure), 100 ether);

        // Secure recipient reverts instead of accepting false return
        vm.expectRevert();
        secure.deposit(IERC20(address(falseToken)), 100 ether);
        vm.stopPrank();
    }

    // --- LAB 5: NO-RETURN TOKEN (USDT) ---
    function test_SecurityLab5_NoReturnTokenSupport() public {
        MockNoReturnToken noRetToken = new MockNoReturnToken(1_000_000 * 1e6);
        SecureNoReturnConsumer secure = new SecureNoReturnConsumer();

        noRetToken.transfer(address(secure), 1000 * 1e6);

        // Secure handler transfers non-standard tokens seamlessly
        secure.transferSafe(IERC20(address(noRetToken)), address(0xCAFE), 500 * 1e6);
        assertEq(noRetToken.balanceOf(address(0xCAFE)), 500 * 1e6);
    }

    // --- LAB 6: REENTRANT TOKEN EXPLOIT ---
    function test_SecurityLab6_ReentrantTokenDefense() public {
        MockReentrantToken reentToken = new MockReentrantToken(1_000_000 ether);
        SecureVaultReentrancy secure = new SecureVaultReentrancy();

        address user = address(0x555);
        reentToken.transfer(user, 1000 ether);

        vm.startPrank(user);
        reentToken.approve(address(secure), 1000 ether);
        secure.deposit(IERC20(address(reentToken)), 1000 ether);

        // Secure withdraw executes CEI and nonReentrant lock
        secure.withdraw(IERC20(address(reentToken)), 1000 ether);
        assertEq(secure.deposits(user), 0);
        vm.stopPrank();
    }

    // --- LAB 7: FEE-ON-TRANSFER ---
    function test_SecurityLab7_FeeOnTransferBalanceDelta() public {
        MockFeeOnTransferToken fotToken = new MockFeeOnTransferToken(1_000_000 ether);
        SecureFeeOnTransferVault secure = new SecureFeeOnTransferVault();

        fotToken.approve(address(secure), 1000 ether);
        uint256 actualReceived = secure.deposit(IERC20(address(fotToken)), 1000 ether);

        // 10% fee was deducted -> exactly 900 ether received & credited
        assertEq(actualReceived, 900 ether);
        assertEq(secure.creditedBalance(address(this)), 900 ether);
    }

    // --- LAB 8: REBASING SHARE VAULT ---
    function test_SecurityLab8_RebasingShareVault() public {
        MockRebasingToken rebaseToken = new MockRebasingToken(1_000_000 ether);
        SecureRebasingShareVault shareVault = new SecureRebasingShareVault();

        address alice = address(0xAA1);
        rebaseToken.transfer(alice, 1000 ether);

        vm.startPrank(alice);
        rebaseToken.approve(address(shareVault), 1000 ether);
        uint256 shares = shareVault.deposit(IERC20(address(rebaseToken)), 1000 ether);
        assertEq(shares, 1000 ether);

        // Token rebases down by 50% (multiplier 0.5e18)
        rebaseToken.rebase(0.5e18);

        // Alice withdraws all shares -> receives 500 ether (her exact 50% share of remaining assets)
        uint256 assetsReturned = shareVault.withdraw(IERC20(address(rebaseToken)), shares);
        assertEq(assetsReturned, 500 ether);
        vm.stopPrank();
    }

    // --- LAB 9: DECIMAL SCALING ---
    function test_SecurityLab9_DecimalScaling() public {
        SecureMultiDecimalSwap swap = new SecureMultiDecimalSwap();

        // 100 USDC (6 decimals: 100 * 1e6) converted to DAI (18 decimals)
        uint256 daiOut = swap.swapWithDecimalScaling(100 * 1e6, 6, 18);
        assertEq(daiOut, 100 * 1e18);

        // 100 DAI (18 decimals: 100 * 1e18) converted to USDC (6 decimals)
        uint256 usdcOut = swap.swapWithDecimalScaling(100 * 1e18, 18, 6);
        assertEq(usdcOut, 100 * 1e6);
    }

    // --- LAB 10: CONTRACT BINDING IN DIGEST ---
    function test_SecurityLab10_ContractBindingInDigest() public {
        SecurePermitWithDomainSeparator secure1 = new SecurePermitWithDomainSeparator();
        SecurePermitWithDomainSeparator secure2 = new SecurePermitWithDomainSeparator();

        // Domain separators are distinct because address(this) is different
        assertTrue(secure1.DOMAIN_SEPARATOR() != secure2.DOMAIN_SEPARATOR());
    }

    // --- LAB 11 & 12: NONCE TRACKING ---
    function test_SecurityLab12_NonceTrackingPreventsReplay() public {
        SecureNonceTrackingPermit secure = new SecureNonceTrackingPermit();
        uint256 pk = 0xBEEF;
        address signer = vm.addr(pk);

        bytes32 digest1 = keccak256(abi.encode(signer, address(0x1), 100 ether, secure.nonces(signer)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest1);

        // First permit succeeds and increments nonce
        secure.permitWithNonce(signer, address(0x1), 100 ether, v, r, s);
        assertEq(secure.nonces(signer), 1);

        // Replay fails
        vm.expectRevert();
        secure.permitWithNonce(signer, address(0x1), 100 ether, v, r, s);
    }
}
