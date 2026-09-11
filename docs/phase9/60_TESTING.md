# 60 — Comprehensive Testing Strategy

## 1. Indexer Verification Layers
1. **Event Decoder Tests**: Bit-level validation of event ABI unpackers.
2. **Reorg Rollback Tests**: Ingestion, branch replacement, and state restoration.
3. **Price Normalization Tests**: Multi-decimal scaling accuracy.
4. **Reconciliation Tests**: Detection of injected reserve divergences.
5. **API Resolvers & Pagination Tests**: Cursor correctness and filtering bounds.
