# 05 — ABI Architecture & TypeScript `as const` Typing

## 1. Zero-Fragment ABI Standard
- ABIs for `SageFactory`, `SagePair`, `SagePermitRouter`, `Permit2`, `ERC20`, and `WETH` are defined once with TypeScript `as const` assertion.
- Enables complete compile-time type safety for all Viem `readContract` and `writeContract` calls.
