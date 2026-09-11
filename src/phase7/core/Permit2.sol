// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IPermit2} from "../interfaces/IPermit2.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {IERC20} from "../../phase2/interfaces/IERC20.sol";

/**
 * @title Permit2
 * @notice Canonical next-generation token authorization and signature transfer protocol.
 */
contract Permit2 is IPermit2 {
    error SignatureExpired();
    error InvalidSignature();
    error InvalidNonce();
    error InsufficientAllowance();
    error AllowanceExpired();
    error ExcessiveInvalidation();
    error ZeroAddress();

    string public constant name = "Permit2";

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant PERMIT_DETAILS_TYPEHASH =
        keccak256("PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)");

    bytes32 public constant PERMIT_SINGLE_TYPEHASH =
        keccak256(
            "PermitSingle(PermitDetails details,address spender,uint256 sigDeadline)PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)"
        );

    bytes32 public constant TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");

    bytes32 public constant PERMIT_TRANSFER_FROM_TYPEHASH =
        keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

    // user => token => spender => PackedAllowance
    mapping(address => mapping(address => mapping(address => PackedAllowance))) public override allowance;

    // user => wordPos => bitmap
    mapping(address => mapping(uint256 => uint256)) public override nonceBitmap;

    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        return keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this)));
    }

    // ========================================================
    // ALLOWANCE SIGNATURE PERMIT
    // ========================================================
    function permit(
        address owner,
        PermitSingle calldata permitSingle,
        bytes calldata signature
    ) external override {
        if (block.timestamp > permitSingle.sigDeadline) revert SignatureExpired();

        PackedAllowance storage allowed = allowance[owner][permitSingle.details.token][permitSingle.spender];
        if (permitSingle.details.nonce != allowed.nonce) revert InvalidNonce();

        bytes32 dataHash = keccak256(
            abi.encode(
                PERMIT_SINGLE_TYPEHASH,
                keccak256(
                    abi.encode(
                        PERMIT_DETAILS_TYPEHASH,
                        permitSingle.details.token,
                        permitSingle.details.amount,
                        permitSingle.details.expiration,
                        permitSingle.details.nonce
                    )
                ),
                permitSingle.spender,
                permitSingle.sigDeadline
            )
        );

        _verifySignature(owner, dataHash, signature);

        // Store new allowance and increment nonce
        allowed.amount = permitSingle.details.amount;
        allowed.expiration = permitSingle.details.expiration;
        allowed.nonce = permitSingle.details.nonce + 1;
    }

    // ========================================================
    // ALLOWANCE-BASED TRANSFER FROM
    // ========================================================
    function transferFrom(
        address from,
        address to,
        uint160 amount,
        address token
    ) external override {
        PackedAllowance storage allowed = allowance[from][token][msg.sender];

        if (block.timestamp > allowed.expiration) revert AllowanceExpired();
        uint160 currentAmount = allowed.amount;
        if (currentAmount < amount) revert InsufficientAllowance();

        if (currentAmount != type(uint160).max) {
            allowed.amount = currentAmount - amount;
        }

        SafeTokenTransfer.safeTransferFrom(IERC20(token), from, to, amount);
    }

    // ========================================================
    // SIGNATURE TRANSFER FROM (DIRECT TRANSFER)
    // ========================================================
    function permitTransferFrom(
        PermitTransferFrom calldata permitDetails,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external override {
        if (block.timestamp > permitDetails.deadline) revert SignatureExpired();
        if (transferDetails.requestedAmount > permitDetails.permitted.amount) revert InsufficientAllowance();

        _useUnorderedNonce(owner, permitDetails.nonce);

        bytes32 dataHash = keccak256(
            abi.encode(
                PERMIT_TRANSFER_FROM_TYPEHASH,
                keccak256(abi.encode(TOKEN_PERMISSIONS_TYPEHASH, permitDetails.permitted.token, permitDetails.permitted.amount)),
                msg.sender,
                permitDetails.nonce,
                permitDetails.deadline
            )
        );

        _verifySignature(owner, dataHash, signature);

        SafeTokenTransfer.safeTransferFrom(
            IERC20(permitDetails.permitted.token),
            owner,
            transferDetails.to,
            transferDetails.requestedAmount
        );
    }

    // ========================================================
    // SIGNATURE WITNESS TRANSFER FROM
    // ========================================================
    function permitWitnessTransferFrom(
        PermitTransferFrom calldata permitDetails,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external override {
        if (block.timestamp > permitDetails.deadline) revert SignatureExpired();
        if (transferDetails.requestedAmount > permitDetails.permitted.amount) revert InsufficientAllowance();

        _useUnorderedNonce(owner, permitDetails.nonce);

        bytes32 typeHash = keccak256(
            abi.encodePacked(
                "PermitWitnessTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline,",
                witnessTypeString,
                ")TokenPermissions(address token,uint256 amount)"
            )
        );

        bytes32 dataHash = keccak256(
            abi.encode(
                typeHash,
                keccak256(abi.encode(TOKEN_PERMISSIONS_TYPEHASH, permitDetails.permitted.token, permitDetails.permitted.amount)),
                msg.sender,
                permitDetails.nonce,
                permitDetails.deadline,
                witness
            )
        );

        _verifySignature(owner, dataHash, signature);

        SafeTokenTransfer.safeTransferFrom(
            IERC20(permitDetails.permitted.token),
            owner,
            transferDetails.to,
            transferDetails.requestedAmount
        );
    }

    // ========================================================
    // NONCE INVALIDATION
    // ========================================================
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external override {
        nonceBitmap[msg.sender][wordPos] |= mask;
    }

    function _useUnorderedNonce(address from, uint256 nonce) internal {
        uint256 wordPos = nonce >> 8;
        uint256 bitPos = nonce & 0xff;
        uint256 mask = 1 << bitPos;

        uint256 word = nonceBitmap[from][wordPos];
        if (word & mask != 0) revert InvalidNonce();

        nonceBitmap[from][wordPos] = word | mask;
    }

    function _verifySignature(
        address signer,
        bytes32 dataHash,
        bytes calldata signature
    ) internal view {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), dataHash));
        address recovered = _recoverSigner(digest, signature);
        if (recovered == address(0) || recovered != signer) revert InvalidSignature();
    }

    function _recoverSigner(bytes32 digest, bytes calldata signature) internal pure returns (address) {
        if (signature.length != 65) return address(0);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 0x20))
            v := byte(0, calldataload(add(signature.offset, 0x40)))
        }
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D57617F83A26633E977373E29B0EA5B) {
            return address(0);
        }
        if (v != 27 && v != 28) return address(0);
        return ecrecover(digest, v, r, s);
    }
}
