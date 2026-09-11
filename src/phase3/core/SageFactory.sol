// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageFactory} from "../interfaces/ISageAMM.sol";
import {SagePair} from "./SagePair.sol";

/**
 * @title SageFactory
 * @notice Factory for creating and indexing deterministic Constant-Product Sage AMM Pairs via CREATE2.
 */
contract SageFactory is ISageFactory {
    // Custom Errors
    error IdenticalAddresses();
    error ZeroAddress();
    error PairExists();
    error Unauthorized();

    address public override feeTo;
    address public override feeToSetter;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor(address _feeToSetter) {
        if (_feeToSetter == address(0)) revert ZeroAddress();
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        if (tokenA == tokenB) revert IdenticalAddresses();
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert ZeroAddress();
        if (getPair[token0][token1] != address(0)) revert PairExists();

        bytes memory bytecode = type(SagePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        SagePair(pair).initialize(token0, token1);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // Bidirectional lookup
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        if (msg.sender != feeToSetter) revert Unauthorized();
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        if (msg.sender != feeToSetter) revert Unauthorized();
        if (_feeToSetter == address(0)) revert ZeroAddress();
        feeToSetter = _feeToSetter;
    }
}
