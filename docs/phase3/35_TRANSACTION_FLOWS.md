# 35 — Core Transaction Execution Flows

## Master AMM Transaction Execution Lifecycles

### Flow 1: Create Pool
```
User ──[ createPair(TokenA, TokenB) ]──> Factory ──[ CREATE2 ]──> Pair Deployed ──[ emit PairCreated ]
```

### Flow 2: Add Liquidity
```
User ──[ Transfer Token0 + Token1 ]──> Pair ──[ mint(to) ]──> LP Shares Minted ──[ emit Mint ]
```

### Flow 3: Execute Swap
```
Trader ──[ Transfer Input Token ]──> Pair ──[ swap(out0, out1, to, data) ]──> Invariant Verified ──[ emit Swap ]
```

### Flow 4: Remove Liquidity
```
LP ──[ Transfer LP Shares ]──> Pair ──[ burn(to) ]──> Proportional Tokens Returned ──[ emit Burn ]
```
