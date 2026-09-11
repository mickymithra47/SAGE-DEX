// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, IERC20Permit} from "../../phase2/interfaces/IERC20.sol";
import {IPermit2} from "../interfaces/IPermit2.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";

// ==========================================
// MINI PROJECT 1: ERC-20 EXACT APPROVAL LAB
// ==========================================
contract Project1_ERC20ExactApprovalLab {
    function transferExact(address token, address from, address to, uint256 amount) external {
        SafeTokenTransfer.safeTransferFrom(IERC20(token), from, to, amount);
    }
}

// ==========================================
// MINI PROJECT 2: EIP-2612 PERMIT LAB
// ==========================================
contract Project2_EIP2612PermitLab {
    function executePermit(
        address token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20Permit(token).permit(owner, spender, value, deadline, v, r, s);
    }
}

// ==========================================
// MINI PROJECT 3: EIP-712 SIGNATURE LAB
// ==========================================
contract Project3_EIP712SignatureLab {
    function computeDigest(bytes32 domainSeparator, bytes32 structHash) external pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// ==========================================
// MINI PROJECT 4: NONCE REPLAY PROTECTION LAB
// ==========================================
contract Project4_NonceReplayProtectionLab {
    mapping(address => uint256) public nonces;

    function useNonce(address user, uint256 expectedNonce) external {
        require(nonces[user] == expectedNonce, "InvalidNonce");
        nonces[user]++;
    }
}

// ==========================================
// MINI PROJECT 5: SIGNATURE EXPIRATION LAB
// ==========================================
contract Project5_SignatureExpirationLab {
    function verifyFreshness(uint256 deadline) external view {
        require(block.timestamp <= deadline, "Expired");
    }
}

// ==========================================
// MINI PROJECT 6: SPENDER/TOKEN/CHAIN BINDING
// ==========================================
contract Project6_SpenderTokenChainBindingLab {
    function verifyBinding(
        address expectedSpender,
        address actualSpender,
        address expectedToken,
        address actualToken,
        uint256 expectedChainId
    ) external view returns (bool) {
        return (expectedSpender == actualSpender &&
            expectedToken == actualToken &&
            block.chainid == expectedChainId);
    }
}

// ==========================================
// MINI PROJECT 7: PERMIT2 INTEGRATION LAB
// ==========================================
contract Project7_Permit2IntegrationLab {
    address public immutable permit2;

    constructor(address _permit2) {
        permit2 = _permit2;
    }

    function transferWithPermit2(
        IPermit2.PermitTransferFrom calldata permitDetails,
        address owner,
        address to,
        uint256 amount,
        bytes calldata signature
    ) external {
        IPermit2(permit2).permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: to, requestedAmount: amount}),
            owner,
            signature
        );
    }
}

// ==========================================
// MINI PROJECT 8: PERMIT + SWAP ATOMIC EXECUTION
// ==========================================
contract Project8_PermitSwapAtomicExecution {
    function atomicValidation(bool permitPassed, bool swapPassed) external pure {
        require(permitPassed, "PermitFailed");
        require(swapPassed, "SwapFailed");
    }
}

// ==========================================
// MINI PROJECT 9: MALICIOUS SIGNATURE LAB
// ==========================================
contract Project9_MaliciousSignatureLaboratory {
    function checkMalleability(bytes32 s) external pure returns (bool isCanonical) {
        isCanonical = (uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D57617F83A26633E977373E29B0EA5B);
    }
}

// ==========================================
// MINI PROJECT 10: APPROVAL SECURITY TEST SUITE
// ==========================================
contract Project10_ApprovalSecurityTestSuite {
    function verifySufficientAllowance(
        address token,
        address owner,
        address spender,
        uint256 requiredAmount
    ) external view returns (bool) {
        return IERC20(token).allowance(owner, spender) >= requiredAmount;
    }
}

// ==========================================
// MINI PROJECT 11: DIFFERENTIAL TESTER
// ==========================================
contract Project11_ApprovalVsSignatureDifferentialTester {
    function compareOutcomes(uint256 balApprove, uint256 balPermit) external pure returns (bool isIdentical) {
        isIdentical = (balApprove == balPermit);
    }
}

// ==========================================
// MINI PROJECT 12: COMPLETE AUTHORIZATION LAYER
// ==========================================
contract Project12_CompleteAuthorizationLayer {
    address public immutable permit2;

    constructor(address _permit2) {
        permit2 = _permit2;
    }
}
