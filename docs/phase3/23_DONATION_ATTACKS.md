# 23 — Direct Token Donation Attacks & Skim/Sync Defenses

## 1. Direct Donation Attack Vector
An attacker transfers $1,000$ units of Token0 directly to the Pair address without calling `mint()` or `swap()`:

```
Before Donation:
  Physical Balances: (100 Token0, 100 Token1)
  Stored Reserves:   (100 Token0, 100 Token1)

Attacker executes: Token0.transfer(Pair, 1000)

After Donation:
  Physical Balances: (1100 Token0, 100 Token1)
  Stored Reserves:   (100 Token0, 100 Token1)  <-- Stored reserves protect pricing!
```

---

## 2. Mitigation Protocols

1. **Stored Reserves Isolate Swap Math**: Swaps calculate input amounts relative to `reserve0`, treating the $1,000$ excess tokens as unindexed collateral.
2. **`skim(address to)` Protocol**:
   Anyone can call `pair.skim(to)` to sweep the $1,000$ donated tokens to an external collector without disturbing pool reserves:
   $$\text{excess0} = \text{balance0} - \text{reserve0}$$
3. **`sync()` Protocol**:
   Alternatively, calling `pair.sync()` re-indexes the donated tokens into active reserves, distributing the yield permanently to all existing LP share holders.
