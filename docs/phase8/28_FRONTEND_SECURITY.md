# 28 — Frontend Web3 Security Threat Model

## 1. Web3 Attack Vectors Mitigated
1. **Phishing Injections**: Strict EIP-712 typed data visualization blocks arbitrary blind signing.
2. **Address Spoofing**: All addresses strictly checksummed via Viem `getAddress`.
3. **Malicious RPCs**: Fallback to validated public RPC providers.
4. **XSS & Calldata Tampering**: Zero `dangerouslySetInnerHTML`; typed parameters encoded through verified ABIs.
