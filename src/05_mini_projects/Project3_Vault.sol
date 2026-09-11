// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Project2_ERC20Token} from "./Project2_ERC20Token.sol";

/**
 * @title Project3_Vault
 * @notice Mini-Project 3: Token Vault with fractional share accounting.
 *         Demonstrates:
 *         - Share calculation: shares = (assets * totalShares) / totalAssets
 *         - Rounding direction: round down on deposit & withdraw to favor vault solvency
 *         - Inflation / donation attack mitigation: virtual offset (1e3 virtual shares/assets)
 */
contract Project3_Vault {
    error ZeroAmount();
    error InsufficientShares(uint256 available, uint256 required);
    error TransferFailed();

    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);

    Project2_ERC20Token public immutable asset;

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    uint256 public totalShares;
    mapping(address => uint256) public balanceOfShares;

    // Virtual offset to prevent inflation/donation exploit
    uint256 private constant VIRTUAL_OFFSET = 1e3;

    constructor(Project2_ERC20Token _asset, string memory _name, string memory _symbol) {
        asset = _asset;
        name = _name;
        symbol = _symbol;
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    // Convert assets to shares (rounded DOWN on deposit)
    function convertToShares(uint256 assets) public view returns (uint256) {
        uint256 supply = totalShares + VIRTUAL_OFFSET;
        uint256 total = totalAssets() + VIRTUAL_OFFSET;
        return (assets * supply) / total;
    }

    // Convert shares to assets (rounded DOWN on withdraw)
    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 supply = totalShares + VIRTUAL_OFFSET;
        uint256 total = totalAssets() + VIRTUAL_OFFSET;
        return (shares * total) / supply;
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();

        shares = convertToShares(assets);
        if (shares == 0) revert ZeroAmount();

        // Transfer assets from user to vault
        bool success = asset.transferFrom(msg.sender, address(this), assets);
        if (!success) revert TransferFailed();

        // Mint shares
        totalShares += shares;
        balanceOfShares[receiver] += shares;

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        if (shares == 0) revert ZeroAmount();
        if (msg.sender != owner) revert InsufficientShares(balanceOfShares[owner], shares);

        uint256 userShares = balanceOfShares[owner];
        if (userShares < shares) {
            revert InsufficientShares(userShares, shares);
        }

        assets = convertToAssets(shares);
        if (assets == 0) revert ZeroAmount();

        // Burn shares first (Checks-Effects-Interactions)
        balanceOfShares[owner] = userShares - shares;
        totalShares -= shares;

        // Transfer underlying assets
        bool success = asset.transfer(receiver, assets);
        if (!success) revert TransferFailed();

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
}
