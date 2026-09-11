# 07 — Factory Registry & Lifecycle Architecture

## 1. Responsibilities of the Factory
The `SageFactory` contract acts as the global deployment registry and discovery hub for all AMM pairs.

```
USER / ROUTER
 │
 ├── 1. getPair(TokenA, TokenB) ──> Returns existing Pair address (or address(0))
 │
 └── 2. createPair(TokenA, TokenB)
      │
      ├── Enforces tokenA != tokenB and token0 != address(0)
      ├── Validates that getPair[token0][token1] == address(0) (No duplicates)
      ├── Deploys new SagePair via CREATE2
      ├── Initializes Pair with token0 and token1 addresses
      ├── Registers pair in bidirectional mapping getPair[t0][t1] and getPair[t1][t0]
      ├── Appends pair to allPairs array
      └── Emits PairCreated(token0, token1, pair, allPairsLength)
```

---

## 2. Trust Minimization & Immutability
- **Pair Immutability**: Once deployed, a Pair's `token0`, `token1`, and `factory` are permanently immutable.
- **Permissionless Creation**: Any user or smart contract can deploy a pair for any two valid ERC-20 tokens at any time without administrative whitelisting.
