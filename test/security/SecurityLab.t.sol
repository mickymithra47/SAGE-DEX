// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";

// Lab 1: Reentrancy
import {VulnerableBank, ReentrancyAttacker, SecureBank} from "../../src/06_security_lab/Reentrancy/ReentrancyLab.sol";

// Lab 2: Access Control
import {VulnerableOwner, SecureOwner} from "../../src/06_security_lab/AccessControl/AccessControlLab.sol";

// Lab 3: Tx.origin
import {
    VulnerableTxOriginWallet,
    TxOriginAttacker,
    SecureTxOriginWallet
} from "../../src/06_security_lab/TxOrigin/TxOriginLab.sol";

// Lab 4: Unchecked Call
import {
    VulnerablePayer,
    SecurePayer,
    RejectingReceiver
} from "../../src/06_security_lab/UncheckedCall/UncheckedCallLab.sol";

// Lab 5: Delegatecall Exploit
import {
    VulnerableProxy,
    DelegatecallAttacker,
    SecureProxy
} from "../../src/06_security_lab/DelegatecallExploit/DelegatecallExploitLab.sol";

// Lab 6: Precision Loss
import {
    VulnerableFeeCalculator,
    SecureFeeCalculator
} from "../../src/06_security_lab/PrecisionLoss/PrecisionLossLab.sol";

// Lab 7: Denial of Service
import {
    VulnerableAuction,
    DosAttacker,
    SecurePullAuction
} from "../../src/06_security_lab/DenialOfService/DenialOfServiceLab.sol";

// Lab 8: Malicious Callback
import {
    VulnerableCallbackReceiver,
    MaliciousReceiver,
    SecureCallbackReceiver
} from "../../src/06_security_lab/MaliciousCallback/MaliciousCallbackLab.sol";

// Lab 9: Weird Tokens
import {
    MockFeeOnTransferToken,
    MockNoReturnToken,
    WeirdTokenHandler
} from "../../src/06_security_lab/WeirdTokens/WeirdTokenLab.sol";

contract SecurityLabTest is Test {
    // --- LAB 1: REENTRANCY ---
    function test_SecurityLab1_ReentrancyExploitAndDefense() public {
        VulnerableBank vulnBank = new VulnerableBank();
        SecureBank secureBank = new SecureBank();

        // Fund vulnerable bank with 10 ETH from regular users
        address regularUser = address(0x999);
        vm.deal(regularUser, 10 ether);
        vm.prank(regularUser);
        vulnBank.deposit{value: 10 ether}();

        // Attacker deposits 1 ETH and drains the vulnerable bank
        address attackerUser = address(0x1337);
        vm.deal(attackerUser, 1 ether);
        vm.startPrank(attackerUser);
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(vulnBank));
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        // Vulnerable bank is completely drained!
        assertEq(address(vulnBank).balance, 0);
        assertEq(address(attacker).balance, 11 ether);

        // SECURE DEFENSE VERIFICATION
        vm.deal(regularUser, 10 ether);
        vm.prank(regularUser);
        secureBank.deposit{value: 10 ether}();

        vm.deal(attackerUser, 1 ether);
        vm.startPrank(attackerUser);
        ReentrancyAttacker attacker2 = new ReentrancyAttacker(address(secureBank));
        // Attack fails against secure bank because of CEI and ReentrancyGuard
        vm.expectRevert();
        attacker2.attack{value: 1 ether}();
        vm.stopPrank();
    }

    // --- LAB 2: ACCESS CONTROL ---
    function test_SecurityLab2_AccessControlExploitAndDefense() public {
        VulnerableOwner vuln = new VulnerableOwner();
        SecureOwner secure = new SecureOwner();

        address attacker = address(0xBAD);

        // Attacker hijacks fee and ownership in vulnerable contract
        vm.startPrank(attacker);
        vuln.setProtocolFee(5000); // 50%
        vuln.transferOwnership(attacker);
        assertEq(vuln.owner(), attacker);
        assertEq(vuln.protocolFee(), 5000);

        // Secure contract reverts on unauthorized attempts
        vm.expectRevert(SecureOwner.Unauthorized.selector);
        secure.setProtocolFee(5000);
        vm.stopPrank();
    }

    // --- LAB 3: TX.ORIGIN ---
    function test_SecurityLab3_TxOriginExploitAndDefense() public {
        address victimOwner = address(0x1111111111111111111111111111111111111111);
        vm.deal(victimOwner, 10 ether);

        vm.prank(victimOwner);
        VulnerableTxOriginWallet vulnWallet = new VulnerableTxOriginWallet();
        (bool fundOk, ) = address(vulnWallet).call{value: 5 ether}("");
        assertTrue(fundOk);

        address payable attackerUser = payable(address(uint160(0xAAAA)));
        vm.prank(attackerUser);
        TxOriginAttacker phishingContract = new TxOriginAttacker(address(vulnWallet));

        // Victim interacts with phishing contract (tx.origin is victimOwner!)
        vm.prank(victimOwner, victimOwner); // (msg.sender, tx.origin)
        (bool callOk, ) = address(phishingContract).call{value: 0.1 ether}("");
        assertTrue(callOk);

        // Attacker stole all funds from vulnerable wallet!
        assertEq(address(vulnWallet).balance, 0);
        assertEq(attackerUser.balance, 5 ether);

        // SECURE WALLET DEFENSE
        vm.prank(victimOwner);
        SecureTxOriginWallet secureWallet = new SecureTxOriginWallet();
        (fundOk, ) = address(secureWallet).call{value: 5 ether}("");
        assertTrue(fundOk);

        // Attacker attempts same phishing attack on secure wallet -> REVERTS
        vm.prank(victimOwner, victimOwner);
        TxOriginAttacker phishing2 = new TxOriginAttacker(address(secureWallet));
        (bool secureCallOk, ) = address(phishing2).call{value: 0.1 ether}("");
        assertFalse(secureCallOk); // Phishing fails
        assertEq(address(secureWallet).balance, 5 ether);
    }

    // --- LAB 4: UNCHECKED CALL ---
    function test_SecurityLab4_UncheckedCallAndDefense() public {
        VulnerablePayer vuln = new VulnerablePayer();
        SecurePayer secure = new SecurePayer();
        RejectingReceiver rejector = new RejectingReceiver();

        address user = address(0x111);
        vm.deal(user, 5 ether);

        // In vulnerable payer: call fails silently, user's balance is reset to 0 even though recipient received nothing!
        vm.startPrank(user);
        vuln.deposit{value: 2 ether}();
        vuln.payout(payable(address(rejector)));
        assertEq(vuln.balances(user), 0);
        assertTrue(vuln.hasPaid(user)); // Marked as paid despite transfer failure!

        // In secure payer: reverts cleanly
        secure.deposit{value: 2 ether}();
        vm.expectRevert(SecurePayer.TransferFailed.selector);
        secure.payout(payable(address(rejector)));
        assertEq(secure.balances(user), 2 ether); // Balance protected
        vm.stopPrank();
    }

    // --- LAB 5: DELEGATECALL EXPLOIT ---
    function test_SecurityLab5_DelegatecallStorageHijacking() public {
        address dummyImpl = address(0x123);
        VulnerableProxy vulnProxy = new VulnerableProxy(dummyImpl);
        DelegatecallAttacker attacker = new DelegatecallAttacker();

        address attackerEOA = address(0xDEAD);

        // Attacker calls execute() pointing to attacker logic
        vm.prank(attackerEOA);
        vulnProxy.execute(
            address(attacker),
            abi.encodeWithSelector(DelegatecallAttacker.takeOwnership.selector)
        );

        // Slot 0 (owner) was hijacked!
        assertEq(vulnProxy.owner(), attackerEOA);
    }

    // --- LAB 6: PRECISION LOSS ---
    function test_SecurityLab6_PrecisionLossDemonstration() public {
        VulnerableFeeCalculator vuln = new VulnerableFeeCalculator();
        SecureFeeCalculator secure = new SecureFeeCalculator();

        // 500 wei with 30 bps (0.3%) fee
        // Vulnerable: (500 / 10000) * 30 = 0 * 30 = 0 wei fee (100% loss)
        uint256 feeVuln = vuln.calculateFeeVulnerable(500, 30);
        assertEq(feeVuln, 0);

        // Secure: (500 * 30) / 10000 = 15000 / 10000 = 1 wei fee (Down)
        uint256 feeSecureDown = secure.calculateFeeDown(500, 30);
        assertEq(feeSecureDown, 1);

        // Secure rounded UP: (15000 + 9999) / 10000 = 2 wei fee
        uint256 feeSecureUp = secure.calculateFeeUp(500, 30);
        assertEq(feeSecureUp, 2);
    }

    // --- LAB 7: DENIAL OF SERVICE ---
    function test_SecurityLab7_PushPaymentDosAndPullDefense() public {
        VulnerableAuction vulnAuction = new VulnerableAuction();
        SecurePullAuction secureAuction = new SecurePullAuction();

        address bidder1 = address(0x11);
        address bidder2 = address(0x22);
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);

        // Attacker bids via DoS contract
        DosAttacker attacker = new DosAttacker(address(vulnAuction));
        vm.deal(address(attacker), 5 ether);
        attacker.attack{value: 1 ether}();

        // Legitimate bidder tries to outbid attacker in vulnerable auction -> REVERTS
        vm.prank(bidder1);
        vm.expectRevert();
        vulnAuction.bid{value: 2 ether}();

        // SECURE PULL AUCTION DEFENSE:
        // Bidder 1 bids
        vm.prank(bidder1);
        secureAuction.bid{value: 1 ether}();

        // Bidder 2 outbids Bidder 1 cleanly
        vm.prank(bidder2);
        secureAuction.bid{value: 2 ether}();
        assertEq(secureAuction.highestBidder(), bidder2);

        // Bidder 1 pulls their own refund asynchronously
        uint256 balBefore = bidder1.balance;
        vm.prank(bidder1);
        secureAuction.withdrawRefund();
        assertEq(bidder1.balance, balBefore + 1 ether);
    }

    // --- LAB 8: MALICIOUS CALLBACK ---
    function test_SecurityLab8_MaliciousCallbackDefense() public {
        VulnerableCallbackReceiver vuln = new VulnerableCallbackReceiver();
        SecureCallbackReceiver secure = new SecureCallbackReceiver();

        MaliciousReceiver attacker = new MaliciousReceiver(address(vuln));

        address user = address(0x555);
        vm.deal(user, 10 ether);

        vm.startPrank(user);
        vuln.deposit{value: 5 ether}();
        vuln.performAction(address(attacker), 2 ether);
        assertEq(attacker.attackCount(), 1);

        secure.deposit{value: 5 ether}();
        secure.performAction(address(attacker), 2 ether);
        assertEq(secure.balances(user), 3 ether);
        vm.stopPrank();
    }

    // --- LAB 9: WEIRD TOKENS ---
    function test_SecurityLab9_FeeOnTransferAndNoReturnHandling() public {
        MockFeeOnTransferToken fotToken = new MockFeeOnTransferToken(1_000_000 ether);
        MockNoReturnToken noReturnToken = new MockNoReturnToken(1_000_000 ether);
        WeirdTokenHandler handler = new WeirdTokenHandler();

        // 1. Fee On Transfer Token Deposit
        fotToken.approve(address(handler), 1000 ether);
        uint256 actualReceived = handler.secureDeposit(address(fotToken), 1000 ether);

        // 10% fee taken -> exactly 900 ether received & recorded
        assertEq(actualReceived, 900 ether);
        assertEq(handler.depositedAmount(address(this)), 900 ether);

        // 2. No Return Token Deposit (USDT-style missing boolean return)
        noReturnToken.approve(address(handler), 500 ether);
        uint256 noReturnReceived = handler.secureDeposit(address(noReturnToken), 500 ether);
        assertEq(noReturnReceived, 500 ether);
    }
}
