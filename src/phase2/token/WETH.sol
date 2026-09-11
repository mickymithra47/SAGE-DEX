// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IWETH, IERC20Metadata} from "../interfaces/IERC20.sol";

/**
 * @title WETH
 * @notice Production Canonical Wrapped Ether (WETH9) implementation.
 *         Maintains a strict 1:1 solvency invariant with native ETH: address(this).balance == totalSupply.
 */
contract WETH is IWETH, IERC20Metadata {
    // Custom Errors
    error ZeroAddress();
    error InsufficientBalance(address account, uint256 available, uint256 required);
    error InsufficientAllowance(address spender, uint256 currentAllowance, uint256 required);
    error ETHTransferFailed();

    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    receive() external payable {
        deposit();
    }

    function deposit() public payable override {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public override {
        uint256 senderBal = balanceOf[msg.sender];
        if (senderBal < wad) {
            revert InsufficientBalance(msg.sender, senderBal, wad);
        }

        // Checks-Effects-Interactions
        unchecked {
            balanceOf[msg.sender] = senderBal - wad;
            totalSupply -= wad;
        }

        emit Withdrawal(msg.sender, wad);
        emit Transfer(msg.sender, address(0), wad);

        (bool success, ) = msg.sender.call{value: wad}("");
        if (!success) revert ETHTransferFailed();
    }

    function transfer(address dst, uint256 wad) external override returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function approve(address guy, uint256 wad) external override returns (bool) {
        if (guy == address(0)) revert ZeroAddress();
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transferFrom(address src, address dst, uint256 wad) public override returns (bool) {
        if (dst == address(0)) revert ZeroAddress();

        uint256 srcBalance = balanceOf[src];
        if (srcBalance < wad) {
            revert InsufficientBalance(src, srcBalance, wad);
        }

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            uint256 currentAllowance = allowance[src][msg.sender];
            if (currentAllowance < wad) {
                revert InsufficientAllowance(msg.sender, currentAllowance, wad);
            }
            unchecked {
                allowance[src][msg.sender] = currentAllowance - wad;
            }
            emit Approval(src, msg.sender, allowance[src][msg.sender]);
        }

        unchecked {
            balanceOf[src] = srcBalance - wad;
            balanceOf[dst] += wad;
        }

        emit Transfer(src, dst, wad);
        return true;
    }
}
