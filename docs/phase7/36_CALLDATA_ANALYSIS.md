# 36 — Calldata Footprint & ABI Encoding Optimization

## 1. Calldata Overhead
- Standard swap: ~228 bytes.
- EIP-2612 permit swap: ~324 bytes (includes 65-byte $(v,r,s)$ signature and nonce).
- Permit2 signature swap: ~420 bytes (includes `PermitTransferFrom` struct and signature).
- Calldata cost represents an additional ~1,500 gas at 16 gas/non-zero byte, negligible compared to the UX benefit.
