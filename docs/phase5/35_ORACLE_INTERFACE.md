# 35 — Oracle Interface & Consumer Query Specification

## 1. Off-Chain Oracle Request/Response Schemas

```typescript
interface OracleRequest {
  pair: string;
  tokenIn: string;
  amountIn: string;
  lookbackSeconds: number;   // e.g. 1800 for 30 minutes
}

interface OracleResponse {
  amountOutTWAP: string;
  twapPriceWad: string;
  timeElapsed: number;
  latestObservationTimestamp: number;
}
```
