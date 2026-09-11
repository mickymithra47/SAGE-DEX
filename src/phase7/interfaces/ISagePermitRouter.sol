// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageRouter} from "../../phase6/interfaces/ISageRouter.sol";
import {IPermit2} from "./IPermit2.sol";

/**
 * @title ISagePermitRouter
 * @notice Router interface extended with EIP-2612 and Permit2 swap execution capabilities.
 */
interface ISagePermitRouter is ISageRouter {
    function permit2() external view returns (address);

    function swapExactTokensForTokensWithPermit(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensWithPermit2(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external returns (uint256[] memory amounts);
}
