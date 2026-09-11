// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IPermit2} from "../interfaces/IPermit2.sol";

// ==========================================
// SCENARIO 5: SPENDER FRONT-RUNNING ATTACKER
// ==========================================
contract SpenderFrontRunningAttacker {
    IPermit2 public immutable permit2;

    constructor(IPermit2 _permit2) {
        permit2 = _permit2;
    }

    // Intercepts signature meant for Router and tries to execute it as attacker contract
    function interceptSignature(
        IPermit2.PermitTransferFrom calldata permitDetails,
        address owner,
        bytes calldata signature
    ) external {
        permit2.permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({to: address(this), requestedAmount: permitDetails.permitted.amount}),
            owner,
            signature
        );
    }
}

// ==========================================
// SCENARIO 8: HIGH-S SIGNATURE MALLEABILITY ATTACKER
// ==========================================
contract SignatureMalleabilityTester {
    // Tests that high-s values (> secp256k1n/2) are strictly rejected
    function verifyMalleabilityRejection(bytes32 s) external pure returns (bool isValid) {
        isValid = (uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D57617F83A26633E977373E29B0EA5B);
    }
}
