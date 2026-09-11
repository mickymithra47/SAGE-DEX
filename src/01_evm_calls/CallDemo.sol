// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title CallDemoTarget
 * @notice Target contract to demonstrate EVM regular CALL behavior
 */
contract CallDemoTarget {
    uint256 public valueReceived;
    address public lastCaller;
    string public message;

    event Called(address indexed sender, uint256 value, string message);

    error TargetReverted(string reason);

    function execute(string calldata _msg) external payable returns (address, uint256, uint256) {
        valueReceived += msg.value;
        lastCaller = msg.sender;
        message = _msg;

        emit Called(msg.sender, msg.value, _msg);

        return (msg.sender, msg.value, block.timestamp);
    }

    function willRevert(string calldata reason) external pure {
        revert TargetReverted(reason);
    }
}

/**
 * @title CallDemoCaller
 * @notice Demonstrates low-level `call` opcode behavior:
 *         - Execution context switches to target: address(this) is Target
 *         - msg.sender inside target becomes address(this) of Caller
 *         - msg.value is transferred from Caller to Target
 *         - Storage mutated is inside Target, not Caller
 */
contract CallDemoCaller {
    event CallResult(bool success, bytes data);

    error CallFailed(bytes returnData);

    receive() external payable {}

    function performCall(address target, string calldata msgPayload) external payable returns (bool success, bytes memory data) {
        // High-level low-level call
        (success, data) = target.call{value: msg.value}(
            abi.encodeWithSelector(CallDemoTarget.execute.selector, msgPayload)
        );

        if (!success) {
            revert CallFailed(data);
        }

        emit CallResult(success, data);
    }

    function performRevertingCall(address target, string calldata revertReason) external returns (bool success, bytes memory data) {
        (success, data) = target.call(
            abi.encodeWithSelector(CallDemoTarget.willRevert.selector, revertReason)
        );
        // Note: we do not revert here to demonstrate capturing the revert data
        emit CallResult(success, data);
    }
}
