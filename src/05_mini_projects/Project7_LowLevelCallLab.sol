// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Project7_LowLevelCallLab
 * @notice Mini-Project 7: Low-level call laboratory demonstrating raw EVM execution,
 *         return data size inspection, and precise revert reason bubbling.
 */
contract Project7_LowLevelCallLab {
    event CallExecuted(address indexed target, bool success, uint256 returnDataLength);

    // Executes raw CALL with assembly revert bubbling
    function executeCall(address target, bytes calldata data, uint256 value) external payable returns (bytes memory) {
        (bool success, bytes memory returnData) = target.call{value: value}(data);

        if (!success) {
            // Bubble up the revert reason
            assembly {
                let returndata_size := mload(returnData)
                revert(add(returnData, 0x20), returndata_size)
            }
        }

        emit CallExecuted(target, success, returnData.length);
        return returnData;
    }

    // Executes raw STATICCALL
    function executeStaticcall(address target, bytes calldata data) external view returns (bytes memory) {
        (bool success, bytes memory returnData) = target.staticcall(data);

        if (!success) {
            assembly {
                let returndata_size := mload(returnData)
                revert(add(returnData, 0x20), returndata_size)
            }
        }

        return returnData;
    }

    // Executes raw DELEGATECALL
    function executeDelegatecall(address target, bytes calldata data) external payable returns (bytes memory) {
        (bool success, bytes memory returnData) = target.delegatecall(data);

        if (!success) {
            assembly {
                let returndata_size := mload(returnData)
                revert(add(returnData, 0x20), returndata_size)
            }
        }

        return returnData;
    }
}
