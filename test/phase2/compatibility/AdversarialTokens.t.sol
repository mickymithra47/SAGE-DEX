// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "../../../src/phase2/interfaces/IERC20.sol";
import {TokenCompatibilityChecker} from "../../../src/phase2/libraries/TokenCompatibilityChecker.sol";
import {TokenRegistry} from "../../../src/phase2/token/TokenRegistry.sol";
import {ERC20Token} from "../../../src/phase2/token/ERC20Token.sol";
import {
    MockReentrantToken,
    MockFeeOnTransferToken,
    MockRebasingToken,
    MockBlacklistToken,
    MockPausableToken,
    MockUnusualDecimalsToken,
    MockFalseReturnToken,
    MockNoReturnToken,
    MockRevertingToken,
    MockMaliciousCallbackToken,
    MockTransferRestrictionToken,
    MockApprovalRaceToken
} from "../../../src/phase2/mocks/AdversarialTokens.sol";

contract AdversarialTokensTest is Test {
    TokenCompatibilityChecker internal checker;

    function setUp() public {
        checker = new TokenCompatibilityChecker();
    }

    function test_CompatibilityChecker_StandardToken() public {
        ERC20Token stdToken = new ERC20Token("Standard", "STD", 18, 1_000_000 ether);
        TokenCompatibilityChecker.InspectionResult memory res = checker.inspectToken(address(stdToken), 0);

        assertTrue(res.isContract);
        assertTrue(res.supportsStandardTransfer);
        assertTrue(res.returnsBooleanOnTransfer);
        assertEq(uint8(res.classifiedCategory), uint8(TokenRegistry.TokenCategory.CategoryA_Standard));
    }

    function test_CompatibilityChecker_NoReturnToken() public {
        MockNoReturnToken noRet = new MockNoReturnToken(1_000_000 * 1e6);
        TokenCompatibilityChecker.InspectionResult memory res = checker.inspectToken(address(noRet), 0);

        assertTrue(res.isContract);
        assertFalse(res.returnsBooleanOnTransfer);
        assertEq(uint8(res.classifiedCategory), uint8(TokenRegistry.TokenCategory.CategoryB_NonStandard));
    }

    function test_CompatibilityChecker_FeeOnTransferToken() public {
        MockFeeOnTransferToken fot = new MockFeeOnTransferToken(1_000_000 ether);
        // Fund checker with tokens (takes 10% fee on transfer, so checker receives 1800 ether)
        fot.transfer(address(checker), 2000 ether);

        TokenCompatibilityChecker.InspectionResult memory res = checker.inspectToken(address(fot), 500 ether);

        assertTrue(res.hasFeeOnTransfer);
        assertEq(res.feeBps, 1000); // 10%
        assertEq(uint8(res.classifiedCategory), uint8(TokenRegistry.TokenCategory.CategoryC_FeeOnTransfer));
    }

    function test_CompatibilityChecker_RevertingToken() public {
        MockRevertingToken rev = new MockRevertingToken();
        TokenCompatibilityChecker.InspectionResult memory res = checker.inspectToken(address(rev), 0);

        assertFalse(res.supportsStandardTransfer);
        assertEq(uint8(res.classifiedCategory), uint8(TokenRegistry.TokenCategory.CategoryF_Unsupported));
    }

    function test_BlacklistAndPausableTokenBehaviors() public {
        MockBlacklistToken bToken = new MockBlacklistToken(1000 ether);
        MockPausableToken pToken = new MockPausableToken(1000 ether);

        // Blacklist test
        bToken.setBlacklist(address(this), true);
        vm.expectRevert("Sender blacklisted");
        bToken.transfer(address(0x1), 10 ether);

        // Pausable test
        pToken.setPaused(true);
        vm.expectRevert("Transfers paused");
        pToken.transfer(address(0x1), 10 ether);
    }
}
