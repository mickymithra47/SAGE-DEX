# 33 — Malicious Signature & Tamper Injection Suite

## 1. Tamper Scenarios Tested
- Tampered owner address -> `InvalidSignature()`.
- Tampered token address -> `InvalidSignature()`.
- Tampered amount -> `InvalidSignature()`.
- Tampered nonce -> `InvalidSignature()`.
- Tampered deadline -> `InvalidSignature()`.
- High-$s$ signature manipulation -> Low-$s$ check triggers `InvalidSignature()`.
