// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title ChildInstance
 * @notice Contract created dynamically
 */
contract ChildInstance {
    address public immutable creator;
    uint256 public immutable creationTimestamp;
    uint256 public value;

    constructor(uint256 _value) {
        creator = msg.sender;
        creationTimestamp = block.timestamp;
        value = _value;
    }

    function setValue(uint256 _newVal) external {
        value = _newVal;
    }
}

/**
 * @title CreateFactory
 * @notice Demonstrates CREATE opcode:
 *         - Address depends on sender address and sender's transaction nonce:
 *           address = keccak256(rlp.encode([sender, nonce]))[12:]
 */
contract CreateFactory {
    event ContractCreated(address indexed childAddress, uint256 value);

    function deployChild(uint256 _value) external returns (address child) {
        ChildInstance instance = new ChildInstance(_value);
        child = address(instance);
        emit ContractCreated(child, _value);
    }
}

/**
 * @title Create2Deployer
 * @notice Demonstrates CREATE2 opcode:
 *         - Address depends deterministically on:
 *           keccak256(0xff ++ senderAddress ++ salt ++ keccak256(initCode))[12:]
 *         - Essential for DEX pairs / Singleton pools with precomputable addresses
 */
contract Create2Deployer {
    event DeployedCreate2(address indexed deployedAddress, bytes32 indexed salt);

    error DeploymentFailed();

    function deploy(bytes32 salt, uint256 initVal) external returns (address deployedAddress) {
        bytes memory bytecode = abi.encodePacked(
            type(ChildInstance).creationCode,
            abi.encode(initVal)
        );

        assembly {
            deployedAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        if (deployedAddress == address(0)) {
            revert DeploymentFailed();
        }

        emit DeployedCreate2(deployedAddress, salt);
    }

    function computeAddress(bytes32 salt, uint256 initVal) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(ChildInstance).creationCode,
            abi.encode(initVal)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }
}
