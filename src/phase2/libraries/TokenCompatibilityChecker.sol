// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, IERC20Metadata} from "../interfaces/IERC20.sol";
import {TokenRegistry} from "../token/TokenRegistry.sol";

/**
 * @title TokenCompatibilityChecker
 * @notice On-chain diagnostic tool that inspects token contract behavior and classifies compatibility.
 */
contract TokenCompatibilityChecker {
    struct InspectionResult {
        bool isContract;
        bool hasMetadata;
        uint8 decimals;
        bool supportsStandardTransfer;
        bool returnsBooleanOnTransfer;
        bool hasFeeOnTransfer;
        uint256 feeBps;
        TokenRegistry.TokenCategory classifiedCategory;
    }

    function inspectToken(address token, uint256 testAmount) external returns (InspectionResult memory result) {
        if (token.code.length == 0) {
            result.isContract = false;
            result.classifiedCategory = TokenRegistry.TokenCategory.CategoryF_Unsupported;
            return result;
        }

        result.isContract = true;

        // 1. Check Metadata
        try IERC20Metadata(token).decimals() returns (uint8 _dec) {
            result.hasMetadata = true;
            result.decimals = _dec;
        } catch {
            result.hasMetadata = false;
            result.decimals = 18;
        }

        // 2. Check Transfer Behavior
        bytes memory transferPayload = abi.encodeWithSelector(IERC20.transfer.selector, address(this), 0);
        (bool success, bytes memory returndata) = token.call(transferPayload);

        if (!success) {
            result.supportsStandardTransfer = false;
            result.classifiedCategory = TokenRegistry.TokenCategory.CategoryF_Unsupported;
            return result;
        }

        result.supportsStandardTransfer = true;

        // 3. Check Return Data Size
        if (returndata.length == 0) {
            result.returnsBooleanOnTransfer = false;
            result.classifiedCategory = TokenRegistry.TokenCategory.CategoryB_NonStandard;
        } else if (returndata.length >= 32) {
            bool returnedVal = abi.decode(returndata, (bool));
            result.returnsBooleanOnTransfer = returnedVal;
            if (returnedVal) {
                result.classifiedCategory = TokenRegistry.TokenCategory.CategoryA_Standard;
            } else {
                result.classifiedCategory = TokenRegistry.TokenCategory.CategoryF_Unsupported;
            }
        }

        // 4. Test Balance Delta for Fee-on-Transfer (if funded with testAmount)
        uint256 myBalBefore = IERC20(token).balanceOf(address(this));
        if (myBalBefore >= testAmount && testAmount > 0) {
            (bool transferOk, ) = token.call(
                abi.encodeWithSelector(IERC20.transfer.selector, address(0x9999), testAmount)
            );
            if (transferOk) {
                uint256 recipientBal = IERC20(token).balanceOf(address(0x9999));
                if (recipientBal < testAmount) {
                    result.hasFeeOnTransfer = true;
                    result.feeBps = ((testAmount - recipientBal) * 10_000) / testAmount;
                    result.classifiedCategory = TokenRegistry.TokenCategory.CategoryC_FeeOnTransfer;
                }
            }
        }
    }
}
