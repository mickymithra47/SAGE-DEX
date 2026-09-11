# 34 — Off-Chain Quote Interface & Data Contract Specification

## 1. Off-Chain Quoting Request/Response Schemas

```typescript
interface QuoteRequest {
  tokenIn: string;
  tokenOut: string;
  amountIn?: string;         // Exact input
  amountOut?: string;        // Exact output
  path?: string[];           // Multi-hop route
  slippageBps: number;       // e.g. 50 = 0.50%
}

interface QuoteResponse {
  amountIn: string;
  amountOut: string;
  minAmountOut: string;      // Bound under slippage
  maxAmountIn: string;       // Bound under slippage
  spotPriceWad: string;      // 18-decimal fixed point
  executionPriceWad: string;
  priceImpactBps: number;
  feeAmount: string;
}
```
