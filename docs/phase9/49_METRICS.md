# 49 — Quantitative Metrics Specification

## 1. Metrics Catalog
- `blocks_processed_total`: Monotonic counter of ingested blocks.
- `events_processed_total`: Monotonic counter of decoded logs.
- `indexer_lag_blocks`: Real-time gauge of distance to blockchain tip.
- `reorgs_total`: Counter of detected chain reorganizations.
- `reconciliation_mismatches_total`: Counter of reserve divergences.
