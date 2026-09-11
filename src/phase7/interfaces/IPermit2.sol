// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title IPermit2
 * @notice Canonical Permit2 interface for signature-based token authorizations and transfers.
 */
interface IPermit2 {
    struct TokenPermissions {
        address token;
        uint256 amount;
    }

    struct PermitTransferFrom {
        TokenPermissions permitted;
        uint256 nonce;
        uint256 deadline;
    }

    struct SignatureTransferDetails {
        address to;
        uint256 requestedAmount;
    }

    struct PermitDetails {
        address token;
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }

    struct PermitSingle {
        PermitDetails details;
        address spender;
        uint256 sigDeadline;
    }

    struct PackedAllowance {
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function allowance(address user, address token, address spender) external view returns (uint160 amount, uint48 expiration, uint48 nonce);

    function permit(address owner, PermitSingle calldata permitSingle, bytes calldata signature) external;

    function permitTransferFrom(
        PermitTransferFrom calldata permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    function permitWitnessTransferFrom(
        PermitTransferFrom calldata permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    function transferFrom(address from, address to, uint160 amount, address token) external;

    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;

    function nonceBitmap(address user, uint256 wordPos) external view returns (uint256);
}
