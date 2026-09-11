# 04 — Typed Contract Address Registry

## 1. Centralized Address Resolution
Contract addresses are bound strictly by chain ID:

```typescript
export interface ChainContracts {
  factory: `0x${string}`;
  router: `0x${string}`;
  permit2: `0x${string}`;
  weth: `0x${string}`;
}
```

- Eliminates hardcoded contract addresses scattered across React components.
