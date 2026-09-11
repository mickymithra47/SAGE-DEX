// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SageRouter} from "../../phase6/core/SageRouter.sol";
import {ISagePermitRouter} from "../interfaces/ISagePermitRouter.sol";
import {IPermit2} from "../interfaces/IPermit2.sol";
import {IERC20Permit} from "../../phase2/interfaces/IERC20.sol";
import {SagePricingLibrary} from "../../phase5/libraries/SagePricingLibrary.sol";

/**
 * @title SagePermitRouter
 * @notice Router implementation with integrated EIP-2612 and Permit2 signature authorization.
 */
contract SagePermitRouter is SageRouter, ISagePermitRouter {
    address public immutable override permit2;

    constructor(
        address _factory,
        address _WETH,
        address _permit2
    ) SageRouter(_factory, _WETH) {
        if (_permit2 == address(0)) revert ZeroAddress();
        permit2 = _permit2;
    }

    // ========================================================
    // ATOMIC EIP-2612 PERMIT + EXACT-INPUT SWAP
    // ========================================================
    function swapExactTokensForTokensWithPermit(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256[] memory amounts) {
        // Execute EIP-2612 permit authorization to approve router
        IERC20Permit(path[0]).permit(msg.sender, address(this), amountIn, deadline, v, r, s);

        // Execute standard exact-input swap
        amounts = swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    // ========================================================
    // ATOMIC PERMIT2 SIGNATURE TRANSFER + EXACT-INPUT SWAP
    // ========================================================
    function swapExactTokensForTokensWithPermit2(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        IPermit2.PermitTransferFrom calldata permitDetails,
        bytes calldata signature
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        if (to == address(0) || to == address(this)) revert InvalidRecipient();
        amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path);
        uint256 amountOut = amounts[amounts.length - 1];
        if (amountOut < amountOutMin) revert InsufficientOutput();

        _pullPermit2(permitDetails, signature, _getPair(path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);

        _emitSwap(path[0], path[path.length - 1], to, amounts[0], amountOut);
    }

    function _pullPermit2(
        IPermit2.PermitTransferFrom calldata permitDetails,
        bytes calldata signature,
        address pair,
        uint256 amount
    ) internal {
        IPermit2(permit2).permitTransferFrom(
            permitDetails,
            IPermit2.SignatureTransferDetails({
                to: pair,
                requestedAmount: amount
            }),
            msg.sender,
            signature
        );
    }

    function _emitSwap(
        address tokenIn,
        address tokenOut,
        address to,
        uint256 amountIn,
        uint256 amountOut
    ) internal {
        emit SwapExecuted(msg.sender, to, tokenIn, tokenOut, amountIn, amountOut);
    }
}
