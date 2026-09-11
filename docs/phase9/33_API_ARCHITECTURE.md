# 33 — API Architecture & Query Routing

## 1. Endpoints & Layering
- **REST Endpoints**:
  - `GET /api/v1/pools`
  - `GET /api/v1/pools/:address`
  - `GET /api/v1/swaps`
  - `GET /api/v1/users/:address/positions`
  - `GET /api/v1/candles`
  - `GET /api/v1/health`
- **GraphQL**: Schema-defined type resolvers with cursor-based pagination.
