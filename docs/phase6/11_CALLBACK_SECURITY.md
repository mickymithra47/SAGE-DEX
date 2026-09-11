# 11 — Pair Callback Security & Sender Authentication

## 1. Callback Model
- `SageRouter` does not implement flash swap receiver callbacks in its base user-facing swap entrypoints.
- All swap calls pass empty `data = ""` to `SagePair.swap()`, preventing any reentrant callback execution.
- If a future flash-loan helper contract implements `sageCall`, it must strictly validate:
  `require(msg.sender == factory.getPair(token0, token1), "UnauthorizedCallback");`
