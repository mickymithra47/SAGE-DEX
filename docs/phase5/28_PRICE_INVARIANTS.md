# 28 — Price & Oracle Protocol Invariants

## Formal Invariant Specifications

```
┌─────────────┬────────────────────────────────────────────────────────────────────────────────────────┐
│ Invariant # │ Mathematical & Architectural Specification                                             │
├─────────────┼────────────────────────────────────────────────────────────────────────────────────────┤
│ Invariant 1 │ getAmountOut(aIn, rIn, rOut) < rOut strictly for all positive finite inputs.           │
│ Invariant 2 │ getAmountIn(aOut, rIn, rOut) is sufficient to produce aOut upon execution.             │
│ Invariant 3 │ Fee calculation (0.3%) never creates unbacked tokens.                                  │
│ Invariant 4 │ Quoting functions yield results identical to core swap execution.                      │
│ Invariant 5 │ Spot price strictly reflects instantaneous reserve ratio.                              │
│ Invariant 6 │ Cumulative price accumulators are monotonically non-decreasing over positive time.    │
│ Invariant 7 │ Elapsed time Δt is never negative.                                                     │
│ Invariant 8 │ TWAP lies strictly within the min and max spot prices observed across the window.      │
│ Invariant 9 │ Quoting and oracle view functions NEVER mutate contract storage state.                 │
│ Invariant 10│ Multi-hop quotes evaluate sequential hops deterministically without precision leakage. │
└─────────────┴────────────────────────────────────────────────────────────────────────────────────────┘
```
