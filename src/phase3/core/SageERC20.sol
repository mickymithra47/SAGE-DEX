// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageERC20} from "../interfaces/ISageAMM.sol";

/**
 * @title SageERC20
 * @notice Standard ERC-20 implementation for AMM Liquidity Provider (LP) share tokens.
 *         Includes EIP-2612 permit functionality with dynamic domain separator.
 */
contract SageERC20 is ISageERC20 {
    // Custom Errors
    error ZeroAddress();
    error InsufficientBalance(address account, uint256 available, uint256 required);
    error InsufficientAllowance(address spender, uint256 currentAllowance, uint256 required);
    error ExpiredDeadline(uint256 deadline, uint256 currentTimestamp);
    error InvalidSigner(address recovered, address expected);
    error InvalidSignatureS();

    string public constant name = "Sage LPs";
    string public constant symbol = "AKR-LP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    // EIP-712 Typehashes
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    uint256 private immutable _INITIAL_CHAIN_ID;
    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;

    constructor() {
        bytes32 hashedName = keccak256(bytes(name));
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

    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert InsufficientAllowance(msg.sender, currentAllowance, amount);
            }
            unchecked {
                allowance[from][msg.sender] = currentAllowance - amount;
            }
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }

        _transfer(from, to, amount);
        return true;
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
        if (block.timestamp > deadline) revert ExpiredDeadline(deadline, block.timestamp);
        if (ownerAccount == address(0) || spender == address(0)) revert ZeroAddress();

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

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));
        address recoveredSigner = ecrecover(digest, v, r, s);
        if (recoveredSigner == address(0) || recoveredSigner != ownerAccount) {
            revert InvalidSigner(recoveredSigner, ownerAccount);
        }

        allowance[ownerAccount][spender] = value;
        emit Approval(ownerAccount, spender, value);
    }

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) revert InsufficientBalance(from, fromBalance, amount);

        unchecked {
            balanceOf[from] = fromBalance - amount;
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0) || to == address(0)) revert ZeroAddress();
        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) revert InsufficientBalance(from, fromBalance, amount);

        unchecked {
            balanceOf[from] = fromBalance - amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
}
