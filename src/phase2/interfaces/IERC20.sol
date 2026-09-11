// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title IERC20
 * @notice Canonical ERC-20 Interface as specified in EIP-20
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/**
 * @title IERC20Metadata
 * @notice Optional ERC-20 Metadata Interface
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
 * @title IERC20Permit
 * @notice EIP-2612 Signature-based Approval Interface
 */
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

/**
 * @title IWETH
 * @notice Wrapped Ether (WETH9) Interface
 */
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}
