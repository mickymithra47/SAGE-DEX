# Phase 11 — Security Architecture & Protocol Defense-in-Depth

## 1. Multi-Layer Security Architecture

```
                                  DEFENSE-IN-DEPTH STACK
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ LAYER 1: MATHEMATICAL INVARIANTS                                                       │
│ • Constant Product: (R0 * 1000 + dx * 997)(R1 * 1000 - dy * 1000) >= R0 * R1 * 1000^2   │
│ • First-Liquidity Inflation Resistance: MINIMUM_LIQUIDITY (1000 wei) burned to 0x0     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 2: ISOLATION & ACCESS CONTROL                                                    │
│ • Reentrancy Mutex: Custom locked modifier preventing reentrant external call loops    │
│ • Factory CREATE2: Deterministic canonical pair deployment (token0 < token1)           │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 3: STATELESS ROUTING & SIGNATURE INTEGRITY                                       │
│ • Router Zero Balance Invariant: Direct pool-to-pool token transfers                   │
│ • Permit2 Cryptographic Binding: Dynamic domain separator, chain ID, bitmap nonces     │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 4: ORACLE MANIPULATION RESISTANCE                                                │
│ • UQ112x112 Cumulative TWAP: Monotonic accumulator resisting single-block price spikes │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ LAYER 5: DERIVED READ MODEL IMMUNITY                                                   │
│ • Indexer Non-Authority: Smart contracts remain 100% authoritative                     │
│ • AI Assistant Sandboxing: Zero private key access, zero autonomous transaction power   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```
