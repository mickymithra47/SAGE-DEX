# 31 — Pure LP Mathematics Library Specification

## 1. Library Interface (`LPPositionMath.sol`)

```solidity
library LPPositionMath {
    // Computes initial LP shares with 1000 minimum liquidity lock
    function calculateInitialLiquidity(uint256 amount0, uint256 amount1, uint256 minLiquidity)
        internal pure returns (uint256 userShares, uint256 lockedShares);

    // Computes additional LP shares minted using min-proportional ratio
    function calculateAdditionalLiquidity(uint256 amount0, uint256 amount1, uint256 reserve0, uint256 reserve1, uint256 totalSupply)
        internal pure returns (uint256 sharesMinted);

    // Computes underlying token redemptions when burning LP shares
    function calculateRedemption(uint256 liquidityShares, uint256 reserve0, uint256 reserve1, uint256 totalSupply)
        internal pure returns (uint256 amount0, uint256 amount1);

    // Computes user ownership fraction in basis points (10,000 = 100.00%)
    function calculateOwnershipBps(uint256 userShares, uint256 totalShares)
        internal pure returns (uint256 ownershipBps);

    // Computes theoretical Impermanent Loss in basis points given price ratio r (18-dec WAD)
    function calculateImpermanentLossBps(uint256 priceRatioWad)
        internal pure returns (uint256 ilBps);

    // Computes total USD valuation of an LP position given external asset prices
    function calculatePositionValue(uint256 userShares, uint256 totalShares, uint256 reserve0, uint256 reserve1, uint256 price0Wad, uint256 price1Wad)
        internal pure returns (uint256 totalValueWad);
}
```
