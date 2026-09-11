# 28 — Route Length Limits & Gas Scaling Analysis

## 1. Practical Hop Scaling Limits

```
┌─────────────────────┬───────────────────┬───────────────────┬────────────────────────────────────────────────┐
│ Hop Count           │ Gas Consumption   │ Fee Retention     │ Feasibility                                    │
├─────────────────────┼───────────────────┼───────────────────┼────────────────────────────────────────────────┤
│ 1 Hop (A -> B)      │ ~88,000 gas       │ 0.30%             │ Optimal / Standard                             │
│ 2 Hops (A -> B -> C)│ ~141,000 gas      │ 0.599%            │ Common for non-base pairs                      │
│ 3 Hops              │ ~195,000 gas      │ 0.897%            │ Occasional exotic token routes                 │
│ 4 Hops              │ ~250,000 gas      │ 1.194%            │ Economically inefficient due to fee friction   │
│ > 5 Hops            │ > 300,000 gas     │ > 1.49%           │ Impractical                                    │
└─────────────────────┴───────────────────┴───────────────────┴────────────────────────────────────────────────┘
```
