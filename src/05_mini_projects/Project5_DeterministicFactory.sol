// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Project5_DeterministicFactory
 * @notice Mini-Project 5: Factory contract for deploying child contracts deterministically via CREATE2.
 */
contract GenericChild {
    address public immutable factory;
    address public immutable owner;
    uint256 public immutable id;

    event Initialized(address factory, address owner, uint256 id);

    constructor(address _owner, uint256 _id) {
        factory = msg.sender;
        owner = _owner;
        id = _id;
        emit Initialized(msg.sender, _owner, _id);
    }
}

contract Project5_DeterministicFactory {
    event ContractDeployed(address indexed deployedAddress, bytes32 indexed salt, address indexed owner, uint256 id);

    error DeploymentFailed();
    error AlreadyDeployed(address existingAddress);

    mapping(bytes32 => address) public deployedContracts;

    function getBytecode(address owner, uint256 id) public pure returns (bytes memory) {
        bytes memory creationCode = type(GenericChild).creationCode;
        return abi.encodePacked(creationCode, abi.encode(owner, id));
    }

    function computeAddress(bytes32 salt, address owner, uint256 id) public view returns (address) {
        bytes memory bytecode = getBytecode(owner, id);
        bytes32 bytecodeHash = keccak256(bytecode);

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                bytecodeHash
            )
        );

        return address(uint160(uint256(hash)));
    }

    function deploy(bytes32 salt, address owner, uint256 id) external returns (address deployedAddress) {
        bytes memory bytecode = getBytecode(owner, id);

        address predicted = computeAddress(salt, owner, id);
        if (predicted.code.length > 0) {
            revert AlreadyDeployed(predicted);
        }

        assembly {
            deployedAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        if (deployedAddress == address(0)) {
            revert DeploymentFailed();
        }

        deployedContracts[salt] = deployedAddress;
        emit ContractDeployed(deployedAddress, salt, owner, id);
    }
}
