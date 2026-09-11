// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20Token} from "./ERC20Token.sol";
import {IERC20Permit} from "../interfaces/IERC20.sol";

/**
 * @title PermitToken
 * @notice Production ERC-20 with EIP-2612 Signature-Based Approvals and EIP-712 Typed Structured Data Hashing.
 *         Protects against cross-chain replay attacks via dynamic chainId tracking.
 */
contract PermitToken is ERC20Token, IERC20Permit {
    // Custom Errors for Permit
    error ExpiredDeadline(uint256 deadline, uint256 currentTimestamp);
    error InvalidSigner(address recovered, address expected);
    error InvalidSignatureS();

    // EIP-712 Typehashes
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;

    mapping(address => uint256) public override nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) ERC20Token(_name, _symbol, _decimals, initialSupply) {
        bytes32 hashedName = keccak256(bytes(_name));
        bytes32 hashedVersion = keccak256(bytes("1"));

        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = _buildDomainSeparator(block.chainid, hashedName, hashedVersion);
    }

    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        if (block.chainid == _INITIAL_CHAIN_ID) {
            return _INITIAL_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(block.chainid, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function permit(
        address ownerAccount,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        if (block.timestamp > deadline) {
            revert ExpiredDeadline(deadline, block.timestamp);
        }
        if (ownerAccount == address(0) || spender == address(0)) {
            revert ZeroAddress();
        }

        // Enforce malleable s-value check (EIP-2)
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D57617F83A266D163F047CE6E14DEF9) {
            revert InvalidSignatureS();
        }

        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                ownerAccount,
                spender,
                value,
                nonces[ownerAccount]++,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );

        address recoveredSigner = ecrecover(digest, v, r, s);
        if (recoveredSigner == address(0) || recoveredSigner != ownerAccount) {
            revert InvalidSigner(recoveredSigner, ownerAccount);
        }

        allowance[ownerAccount][spender] = value;
        emit Approval(ownerAccount, spender, value);
    }

    function _buildDomainSeparator(
        uint256 chainId,
        bytes32 hashedName,
        bytes32 hashedVersion
    ) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                hashedName,
                hashedVersion,
                chainId,
                address(this)
            )
        );
    }
}
