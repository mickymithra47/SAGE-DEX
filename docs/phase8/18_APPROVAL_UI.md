# 18 — ERC-20 Approval Detection & UI Flow

## 1. Multi-Tier Allowance Detection
1. Frontend queries `token.allowance(user, router)`.
2. If `allowance < amountIn`:
   - Button renders `Approve [Token]`.
   - Offers user choice between **Exact Approval** (`amountIn`) and **Unlimited Approval** (`2^256 - 1`).
3. If `allowance >= amountIn`:
   - Button transitions immediately to `Execute Swap`.
