# 13 — LP Position Valuation & On-Chain Query Architecture

## 1. On-Chain Accounting View
`SageLPAccountingEngine.getPosition()` exposes a clean view for indexers and frontends:

```solidity
struct PositionView {
    address pair;
    address user;
    uint256 userShares;
    uint256 totalShares;
    uint256 ownershipBps;      // e.g. 2500 = 25.00%
    uint256 claimableToken0;   // Floor divided claim
    uint256 claimableToken1;   // Floor divided claim
    uint256 reserve0;
    uint256 reserve1;
}
```

---

## 2. Off-Chain Position Valuation Calculation
Given external USD prices $P_0$ and $P_1$:

$$\text{User USD Valuation} = (\text{claimableToken0} \times P_0) + (\text{claimableToken1} \times P_1)$$
