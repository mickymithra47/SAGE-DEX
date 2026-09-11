# 04 — Factory Indexing & Deterministic Pool Discovery

## 1. Event Signature
```solidity
event PairCreated(address indexed token0, address indexed token1, address pair, uint256 allPairsLength);
```
- Topic: `0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9`

---

## 2. Ingestion Rules
1. Extract `token0` and `token1` from indexed event topics.
2. Extract `pair` address and `allPairsLength` from unindexed data.
3. Automatically index and track the new `SagePair` address for subsequent swap and liquidity events.
