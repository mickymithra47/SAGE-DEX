// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Math} from "../../phase3/libraries/Math.sol";

/**
 * @title LPPositionMath
 * @notice Pure mathematical library for LP position calculations, share valuations, and impermanent loss
 */
library LPPositionMath {
    error InsufficientLiquidity();
    error InsufficientInput();
    error ZeroTotalSupply();
    error InsufficientShareBalance();

    uint256 internal constant WAD = 1e18;
    uint256 internal constant BPS = 10_000;

    // Calculates initial LP shares with minimum liquidity locking
    function calculateInitialLiquidity(
        uint256 amount0,
        uint256 amount1,
        uint256 minLiquidity
    ) internal pure returns (uint256 userShares, uint256 lockedShares) {
        if (amount0 == 0 || amount1 == 0) revert InsufficientInput();
        uint256 initial = Math.sqrt(amount0 * amount1);
        if (initial <= minLiquidity) revert InsufficientLiquidity();
        userShares = initial - minLiquidity;
        lockedShares = minLiquidity;
    }

    // Calculates LP shares minted for an existing pool based on minimum proportional ratio
    function calculateAdditionalLiquidity(
        uint256 amount0,
        uint256 amount1,
        uint256 reserve0,
        uint256 reserve1,
        uint256 totalSupply
    ) internal pure returns (uint256 sharesMinted) {
        if (amount0 == 0 || amount1 == 0) revert InsufficientInput();
        if (reserve0 == 0 || reserve1 == 0 || totalSupply == 0) revert InsufficientLiquidity();

        uint256 shares0 = (amount0 * totalSupply) / reserve0;
        uint256 shares1 = (amount1 * totalSupply) / reserve1;
        sharesMinted = Math.min(shares0, shares1);
    }

    // Calculates underlying tokens returned when burning LP shares
    function calculateRedemption(
        uint256 liquidityShares,
        uint256 reserve0,
        uint256 reserve1,
        uint256 totalSupply
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (liquidityShares == 0) revert InsufficientInput();
        if (totalSupply == 0) revert ZeroTotalSupply();

        amount0 = (liquidityShares * reserve0) / totalSupply;
        amount1 = (liquidityShares * reserve1) / totalSupply;
    }

    // Calculates user's ownership fraction in basis points (e.g. 1000 = 10.00%)
    function calculateOwnershipBps(uint256 userShares, uint256 totalShares) internal pure returns (uint256 ownershipBps) {
        if (totalShares == 0 || userShares == 0) return 0;
        if (userShares >= totalShares) return BPS;

        if (userShares <= type(uint256).max / BPS) {
            ownershipBps = (userShares * BPS) / totalShares;
        } else {
            ownershipBps = (userShares / (totalShares / BPS));
        }
    }

    // Calculates theoretical Impermanent Loss in basis points given price ratio r = P_new / P_initial (in 18-dec WAD)
    // Formula: IL(r) = (2 * sqrt(r) / (1 + r)) - 1
    function calculateImpermanentLossBps(uint256 priceRatioWad) internal pure returns (uint256 ilBps) {
        if (priceRatioWad == WAD || priceRatioWad == 0) return 0;

        // sqrt(r * 1e18) = sqrt(r) * 1e9 -> multiply by 1e9 to scale back to 1e18
        uint256 sqrtRWad = Math.sqrt(priceRatioWad * WAD);
        uint256 numerator = 2 * sqrtRWad;
        uint256 denominator = WAD + priceRatioWad;
        uint256 holdRatioWad = (numerator * WAD) / denominator;

        if (WAD > holdRatioWad) {
            ilBps = ((WAD - holdRatioWad) * BPS) / WAD;
        }
    }

    // Calculates total position value in terms of an external base quote asset (e.g. USD in 18-dec WAD)
    function calculatePositionValue(
        uint256 userShares,
        uint256 totalShares,
        uint256 reserve0,
        uint256 reserve1,
        uint256 price0Wad,
        uint256 price1Wad
    ) internal pure returns (uint256 totalValueWad) {
        if (totalShares == 0 || userShares == 0) return 0;
        uint256 claim0 = (userShares * reserve0) / totalShares;
        uint256 claim1 = (userShares * reserve1) / totalShares;

        uint256 val0 = (claim0 * price0Wad) / WAD;
        uint256 val1 = (claim1 * price1Wad) / WAD;
        totalValueWad = val0 + val1;
    }
}
