// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ISageLPPosition} from "../interfaces/ISageLPPosition.sol";
import {ISagePair} from "../../phase3/interfaces/ISageAMM.sol";
import {LPPositionMath} from "../libraries/LPPositionMath.sol";
import {SageMath} from "../../phase3/libraries/SageMath.sol";

/**
 * @title SageLPAccountingEngine
 * @notice On-chain viewer and accounting engine for Sage LP positions
 */
contract SageLPAccountingEngine is ISageLPPosition {
    error ZeroAddress();
    error InsufficientShareBalance();

    function getPosition(address pair, address user) external view override returns (PositionView memory viewData) {
        if (pair == address(0) || user == address(0)) revert ZeroAddress();

        ISagePair pool = ISagePair(pair);
        uint256 userShares = pool.balanceOf(user);
        uint256 totalShares = pool.totalSupply();
        (uint112 r0, uint112 r1, ) = pool.getReserves();

        uint256 ownershipBps = LPPositionMath.calculateOwnershipBps(userShares, totalShares);
        (uint256 claim0, uint256 claim1) = totalShares > 0 && userShares > 0
            ? LPPositionMath.calculateRedemption(userShares, r0, r1, totalShares)
            : (0, 0);

        viewData = PositionView({
            pair: pair,
            user: user,
            userShares: userShares,
            totalShares: totalShares,
            ownershipBps: ownershipBps,
            claimableToken0: claim0,
            claimableToken1: claim1,
            reserve0: r0,
            reserve1: r1
        });
    }

    function quoteAddLiquidity(
        address pair,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view override returns (DepositQuote memory quote) {
        if (pair == address(0)) revert ZeroAddress();

        ISagePair pool = ISagePair(pair);
        (uint112 r0, uint112 r1, ) = pool.getReserves();
        uint256 totalShares = pool.totalSupply();

        if (r0 == 0 && r1 == 0) {
            // Initial Deposit Quote
            (uint256 userShares, ) = LPPositionMath.calculateInitialLiquidity(
                amount0Desired,
                amount1Desired,
                pool.MINIMUM_LIQUIDITY()
            );
            quote = DepositQuote({
                amount0Optimal: amount0Desired,
                amount1Optimal: amount1Desired,
                expectedLiquidityShares: userShares,
                isInitialDeposit: true
            });
        } else {
            // Subsequent Deposit Quote: compute optimal amounts
            uint256 amount1Optimal = SageMath.quote(amount0Desired, r0, r1);
            if (amount1Optimal <= amount1Desired) {
                uint256 shares = LPPositionMath.calculateAdditionalLiquidity(
                    amount0Desired,
                    amount1Optimal,
                    r0,
                    r1,
                    totalShares
                );
                quote = DepositQuote({
                    amount0Optimal: amount0Desired,
                    amount1Optimal: amount1Optimal,
                    expectedLiquidityShares: shares,
                    isInitialDeposit: false
                });
            } else {
                uint256 amount0Optimal = SageMath.quote(amount1Desired, r1, r0);
                uint256 shares = LPPositionMath.calculateAdditionalLiquidity(
                    amount0Optimal,
                    amount1Desired,
                    r0,
                    r1,
                    totalShares
                );
                quote = DepositQuote({
                    amount0Optimal: amount0Optimal,
                    amount1Optimal: amount1Desired,
                    expectedLiquidityShares: shares,
                    isInitialDeposit: false
                });
            }
        }
    }

    function quoteRemoveLiquidity(
        address pair,
        address user,
        uint256 sharesToBurn
    ) external view override returns (WithdrawalQuote memory quote) {
        if (pair == address(0) || user == address(0)) revert ZeroAddress();

        ISagePair pool = ISagePair(pair);
        uint256 userShares = pool.balanceOf(user);
        if (sharesToBurn > userShares) revert InsufficientShareBalance();

        uint256 totalShares = pool.totalSupply();
        (uint112 r0, uint112 r1, ) = pool.getReserves();

        (uint256 a0, uint256 a1) = LPPositionMath.calculateRedemption(sharesToBurn, r0, r1, totalShares);

        uint256 remainingShares = userShares - sharesToBurn;
        uint256 remainingTotal = totalShares - sharesToBurn;
        uint256 remainingBps = LPPositionMath.calculateOwnershipBps(remainingShares, remainingTotal);

        quote = WithdrawalQuote({
            amount0: a0,
            amount1: a1,
            remainingUserShares: remainingShares,
            remainingOwnershipBps: remainingBps
        });
    }
}
