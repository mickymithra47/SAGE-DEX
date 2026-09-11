# 06 — Read Contract Layer & Multicall Optimization

## 1. On-Chain Reads Pipeline
```typescript
const [reserves, balanceIn, balanceOut, allowance] = await Promise.all([
  publicClient.readContract({ address: pairAddress, abi: PAIR_ABI, functionName: 'getReserves' }),
  publicClient.readContract({ address: tokenIn, abi: ERC20_ABI, functionName: 'balanceOf', args: [user] }),
  publicClient.readContract({ address: tokenOut, abi: ERC20_ABI, functionName: 'balanceOf', args: [user] }),
  publicClient.readContract({ address: tokenIn, abi: ERC20_ABI, functionName: 'allowance', args: [user, router] })
]);
```

- Multicall batching minimizes roundtrips to RPC providers.
