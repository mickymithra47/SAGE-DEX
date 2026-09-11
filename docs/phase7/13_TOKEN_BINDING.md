# 13 — Token Binding & Token Substitution Resistance

## 1. Token Binding Invariant
- The token contract address is hashed directly into `TokenPermissions(address token, uint256 amount)`:
  `TOKEN_PERMISSIONS_TYPEHASH = keccak256("TokenPermissions(address token,uint256 amount)")`
- An authorization signed for Token A (e.g. DAI) cannot be used to pull Token B (e.g. USDC).
