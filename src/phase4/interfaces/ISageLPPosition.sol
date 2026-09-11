// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title ISageLPPosition
 * @notice Interface for querying LP positions, deposit quotes, and claimable assets
 */
interface ISageLPPosition {
    struct PositionView {
        address pair;
        address user;
        uint256 userShares;
        uint256 totalShares;
        uint256 ownershipBps; // Basis points (e.g. 2500 = 25.00%)
        uint256 claimableToken0;
        uint256 claimableToken1;
        uint256 reserve0;
        uint256 reserve1;
    }

    struct DepositQuote {
        uint256 amount0Optimal;
        uint256 amount1Optimal;
        uint256 expectedLiquidityShares;
        bool isInitialDeposit;
    }

    struct WithdrawalQuote {
        uint256 amount0;
        uint256 amount1;
        uint256 remainingUserShares;
        uint256 remainingOwnershipBps;
    }

    function getPosition(address pair, address user) external view returns (PositionView memory);
    function quoteAddLiquidity(
        address pair,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view returns (DepositQuote memory);
    function quoteRemoveLiquidity(
        address pair,
        address user,
        uint256 sharesToBurn
    ) external view returns (WithdrawalQuote memory);
}
