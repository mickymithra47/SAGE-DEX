# 39 — Data Freshness & Indexing Lag Metrics

## 1. Lag Quantification
$$\text{Lag (blocks)} = \text{chainTipBlock} - \text{latestIndexedBlock}$$

- Exposes health payload to frontend:
  ```json
  {
    "latestIndexedBlock": "10500197",
    "latestChainBlock": "10500200",
    "indexingLagBlocks": 3,
    "isHealthy": true
  }
  ```
- Allows web UI to warn traders if market data is lagging behind live execution.
