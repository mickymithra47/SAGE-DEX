// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageRouter} from "../interfaces/ISageRouter.sol";
import {ISageFactory, ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {SagePricingLibrary} from "../../phase5/libraries/SagePricingLibrary.sol";
import {SafeTokenTransfer} from "../../phase2/libraries/SafeTokenTransfer.sol";
import {IERC20, IWETH} from "../../phase2/interfaces/IERC20.sol";

/**
 * @title SageRouter
 * @notice Production swap execution coordinator for the SAGE DEX protocol.
 */
contract SageRouter is ISageRouter {
    error Expired();
    error InvalidPath();
    error InvalidRecipient();
    error InsufficientOutput();
    error ExcessiveInput();
    error PairNotFound();
    error TransferFailed();
    error InsufficientETH();
    error ZeroAddress();

    address public immutable override factory;
    address public immutable override WETH;

    event SwapExecuted(
        address indexed sender,
        address indexed recipient,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    modifier ensure(uint256 deadline) {
        if (block.timestamp > deadline) revert Expired();
        _;
    }

    constructor(address _factory, address _WETH) {
        if (_factory == address(0) || _WETH == address(0)) revert ZeroAddress();
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        // Only accept ETH directly from WETH contract on withdrawal
        assert(msg.sender == WETH);
    }

    // ========================================================
    // SWAP: EXACT TOKENS FOR TOKENS
    // ========================================================
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256[] memory amounts) {
        if (to == address(0) || to == address(this)) revert InvalidRecipient();
        amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path);
        if (amounts[amounts.length - 1] < amountOutMin) revert InsufficientOutput();

        address firstPair = _getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);
        _swap(amounts, path, to);

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], amounts[amounts.length - 1]);
    }

    // ========================================================
    // SWAP: TOKENS FOR EXACT TOKENS
    // ========================================================
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        if (to == address(0) || to == address(this)) revert InvalidRecipient();
        amounts = SagePricingLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > amountInMax) revert ExcessiveInput();

        address firstPair = _getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);
        _swap(amounts, path, to);

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], amounts[amounts.length - 1]);
    }

    // ========================================================
    // SWAP: EXACT ETH FOR TOKENS
    // ========================================================
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override ensure(deadline) returns (uint256[] memory amounts) {
        if (path[0] != WETH) revert InvalidPath();
        if (to == address(0) || to == address(this)) revert InvalidRecipient();

        amounts = SagePricingLibrary.getAmountsOut(factory, msg.value, path);
        if (amounts[amounts.length - 1] < amountOutMin) revert InsufficientOutput();

        IWETH(WETH).deposit{value: amounts[0]}();
        address firstPair = _getPair(path[0], path[1]);
        assert(IWETH(WETH).transfer(firstPair, amounts[0]));
        _swap(amounts, path, to);

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], amounts[amounts.length - 1]);
    }

    // ========================================================
    // SWAP: TOKENS FOR EXACT ETH
    // ========================================================
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        if (path[path.length - 1] != WETH) revert InvalidPath();
        if (to == address(0) || to == address(this)) revert InvalidRecipient();

        amounts = SagePricingLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > amountInMax) revert ExcessiveInput();

        address firstPair = _getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);
        _swap(amounts, path, address(this));

        uint256 ethOut = amounts[amounts.length - 1];
        IWETH(WETH).withdraw(ethOut);
        _safeTransferETH(to, ethOut);

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], ethOut);
    }

    // ========================================================
    // SWAP: EXACT TOKENS FOR ETH
    // ========================================================
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256[] memory amounts) {
        if (path[path.length - 1] != WETH) revert InvalidPath();
        if (to == address(0) || to == address(this)) revert InvalidRecipient();

        amounts = SagePricingLibrary.getAmountsOut(factory, amountIn, path);
        uint256 ethOut = amounts[amounts.length - 1];
        if (ethOut < amountOutMin) revert InsufficientOutput();

        address firstPair = _getPair(path[0], path[1]);
        SafeTokenTransfer.safeTransferFrom(IERC20(path[0]), msg.sender, firstPair, amounts[0]);
        _swap(amounts, path, address(this));

        IWETH(WETH).withdraw(ethOut);
        _safeTransferETH(to, ethOut);

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], ethOut);
    }

    // ========================================================
    // SWAP: ETH FOR EXACT TOKENS
    // ========================================================
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override ensure(deadline) returns (uint256[] memory amounts) {
        if (path[0] != WETH) revert InvalidPath();
        if (to == address(0) || to == address(this)) revert InvalidRecipient();

        amounts = SagePricingLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > msg.value) revert ExcessiveInput();

        IWETH(WETH).deposit{value: amounts[0]}();
        address firstPair = _getPair(path[0], path[1]);
        assert(IWETH(WETH).transfer(firstPair, amounts[0]));
        _swap(amounts, path, to);

        // Refund unused ETH
        if (msg.value > amounts[0]) {
            _safeTransferETH(msg.sender, msg.value - amounts[0]);
        }

        emit SwapExecuted(msg.sender, to, path[0], path[path.length - 1], amounts[0], amounts[amounts.length - 1]);
    }

    // ========================================================
    // INTERNAL SEQUENTIAL ROUTE EXECUTION
    // ========================================================
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal {
        for (uint256 i = 0; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            address pair = _getPair(input, output);
            address token0 = ISagePair(pair).token0();

            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));

            address recipient = i < path.length - 2
                ? _getPair(output, path[i + 2])
                : _to;

            ISagePair(pair).swap(amount0Out, amount1Out, recipient, new bytes(0));
        }
    }

    function _getPair(address tokenA, address tokenB) internal view returns (address pair) {
        pair = ISageFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) revert PairNotFound();
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert TransferFailed();
    }
}
