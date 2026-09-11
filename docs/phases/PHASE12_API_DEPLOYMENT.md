# Phase 12 — Query API Deployment & Routing

## 1. API Endpoints
- `GET /api/v1/pools`: Discoverable pool registry and TVL metrics.
- `GET /api/v1/swaps`: Filtered historical trade log with cursor pagination.
- `GET /api/v1/users/:address/positions`: Real-time LP share valuations.
- `GET /api/v1/candles`: Multi-timeframe OHLCV candlesticks (1m, 5m, 1h, 1d).
- `GET /api/v1/health`: Indexer freshness gauge and block lag.
