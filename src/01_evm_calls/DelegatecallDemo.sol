// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title DelegatecallLogic
 * @notice Logic implementation meant to be executed via DELEGATECALL
 */
contract DelegatecallLogic {
    // Storage layout MUST exactly match the proxy's storage layout!
    uint256 public value;
    address public sender;
    address public currentAddress;

    event LogicExecuted(address caller, address currentContract, uint256 val);

    function setValue(uint256 _val) external payable {
        value = _val;
        sender = msg.sender;
        currentAddress = address(this);

        emit LogicExecuted(msg.sender, address(this), _val);
    }
}

/**
 * @title DelegatecallProxy
 * @notice Demonstrates low-level `delegatecall` opcode behavior:
 *         - Code is executed FROM the logic contract
 *         - State changes happen IN THIS proxy contract (same storage slots)
 *         - msg.sender remains the ORIGINAL caller (not the proxy)
 *         - msg.value is preserved
 *         - address(this) remains the proxy address
 */
contract DelegatecallProxy {
    // Storage slot 0
    uint256 public value;
    // Storage slot 1
    address public sender;
    // Storage slot 2
    address public currentAddress;

    error DelegatecallFailed(bytes returnData);

    function executeDelegatecall(address logicContract, uint256 _val) external payable returns (bytes memory) {
        (bool success, bytes memory returnData) = logicContract.delegatecall(
            abi.encodeWithSelector(DelegatecallLogic.setValue.selector, _val)
        );

        if (!success) {
            revert DelegatecallFailed(returnData);
        }

        return returnData;
    }
}
