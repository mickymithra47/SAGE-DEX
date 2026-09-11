// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title StaticcallTarget
 * @notice Target contract used to test STATICCALL constraints
 */
contract StaticcallTarget {
    uint256 public immutable number;
    uint256 public stateVariable;

    constructor(uint256 _number) {
        number = _number;
        stateVariable = 100;
    }

    // Pure/view: Allowed in STATICCALL
    function getCalculation(uint256 x) external view returns (uint256) {
        return number * x + stateVariable;
    }

    // State-modifying: Disallowed in STATICCALL (EVM opcode throws exception)
    function modifyState(uint256 newVal) external returns (uint256) {
        stateVariable = newVal;
        return stateVariable;
    }
}

/**
 * @title StaticcallDemoCaller
 * @notice Demonstrates low-level `staticcall` opcode behavior:
 *         - Guarantees NO state modifications (SSTORE, LOG, CREATE, SELFDESTRUCT, CALL with value are prohibited)
 *         - Reverts if target attempts any state change
 *         - Essential for oracles, view simulations, and reentrancy-safe reads
 */
contract StaticcallDemoCaller {
    error StaticcallFailed(bytes returnData);

    function performStaticcall(address target, uint256 input) external view returns (uint256 result) {
        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSelector(StaticcallTarget.getCalculation.selector, input)
        );

        if (!success) {
            revert StaticcallFailed(data);
        }

        result = abi.decode(data, (uint256));
    }

    function attemptStateMutationViaStaticcall(address target, uint256 newVal) external view returns (bool success, bytes memory data) {
        // Will fail because STATICCALL forbids state mutation in target
        (success, data) = target.staticcall(
            abi.encodeWithSelector(StaticcallTarget.modifyState.selector, newVal)
        );
    }
}
