// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";

/**
 * @title SafeTokenTransfer
 * @notice Production-grade low-level token interaction library.
 *         Properly handles:
 *         1. Standard ERC-20 returning boolean true
 *         2. Non-standard tokens returning empty returndata (USDT)
 *         3. Reverting tokens (bubbles up revert reason)
 *         4. False-returning tokens (treats boolean false as revert)
 */
library SafeTokenTransfer {
    error SafeTransferFailed(address token, address to, uint256 amount);
    error SafeTransferFromFailed(address token, address from, address to, uint256 amount);
    error SafeApproveFailed(address token, address spender, uint256 amount);
    error NonContractAddress(address target);

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        _callOptionalReturn(
            address(token),
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount),
            abi.encodeWithSelector(SafeTransferFailed.selector, address(token), to, amount)
        );
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        _callOptionalReturn(
            address(token),
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount),
            abi.encodeWithSelector(SafeTransferFromFailed.selector, address(token), from, to, amount)
        );
    }

    function safeApprove(IERC20 token, address spender, uint256 amount) internal {
        _callOptionalReturn(
            address(token),
            abi.encodeWithSelector(IERC20.approve.selector, spender, amount),
            abi.encodeWithSelector(SafeApproveFailed.selector, address(token), spender, amount)
        );
    }

    // Handles approve race conditions: sets allowance to 0 before setting new value if non-zero
    function safeApproveWithReset(IERC20 token, address spender, uint256 amount) internal {
        uint256 current = token.allowance(address(this), spender);
        if (current > 0 && amount > 0) {
            safeApprove(token, spender, 0);
        }
        safeApprove(token, spender, amount);
    }

    function _callOptionalReturn(address token, bytes memory data, bytes memory customError) private {
        if (token.code.length == 0) {
            revert NonContractAddress(token);
        }

        assembly {
            // Low-level call to token
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0)
            let returndata_size := returndatasize()

            // If call failed, bubble up the revert reason
            if iszero(success) {
                if iszero(returndata_size) {
                    // Revert with custom error
                    revert(add(customError, 0x20), mload(customError))
                }
                returndatacopy(0x00, 0x00, returndata_size)
                revert(0x00, returndatasize())
            }

            // If call succeeded, verify return data:
            // Valid if: returndatasize == 0 (e.g. USDT) OR (returndatasize >= 32 AND returned uint256 != 0)
            if gt(returndata_size, 0) {
                returndatacopy(0x00, 0x00, 0x20)
                let returnedVal := mload(0x00)
                if iszero(returnedVal) {
                    revert(add(customError, 0x20), mload(customError))
                }
            }
        }
    }
}
