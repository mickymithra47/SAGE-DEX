# 31 — Transaction Index Schema & Gas Metrics

## 1. Transaction Table Schema
- Fields: `chainId`, `hash`, `blockNumber`, `from`, `to`, `status`, `gasUsed`, `effectiveGasPrice`, `timestamp`.
- Links events to top-level transaction origins and execution status.
