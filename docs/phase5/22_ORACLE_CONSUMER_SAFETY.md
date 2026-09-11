# 22 — Oracle Consumer Integration Safety Guidelines

## 1. Safety Checklist for Protocols Integrating Sage TWAP
1. **Verify Minimum TVL**: Enforce a strict minimum liquidity check before accepting a pair as a price feed.
2. **Select Appropriate Lookback**: Use at least 30 minutes (`1800s`) for lending protocol collateral feeds.
3. **Handle Reverts**: Wrap `consult()` in `try/catch` or ensure fallback pricing if the oracle returns `Uninitialized` or `InsufficientHistory`.
4. **Check Price Bounds**: Compare TWAP against sanity bounds (e.g. max 50% shift per hour) to detect market flash crashes.
