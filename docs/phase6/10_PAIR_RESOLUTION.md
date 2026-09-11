# 10 — Pair Resolution & Factory Registry Queries

## 1. Registry Querying
`SageRouter` resolves pool addresses via:
```solidity
function _getPair(address tokenA, address tokenB) internal view returns (address pair) {
    pair = ISageFactory(factory).getPair(tokenA, tokenB);
    if (pair == address(0)) revert PairNotFound();
}
```

---

## 2. Security
- Using `ISageFactory.getPair` guarantees that the router only routes swaps through genuine canonical pairs deployed and registered by the Sage protocol factory.
