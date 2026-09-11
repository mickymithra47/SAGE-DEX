# 44 — RPC Failure Resilience & Retry Strategy

## 1. Retry Strategy
- **Exponential Backoff**: $t_{\text{wait}} = \min(t_{\text{base}} \cdot 2^k, t_{\text{max}})$.
- **Circuit Breaker**: Trips after 10 consecutive RPC timeouts and notifies on-call monitoring.
- **Provider Failover**: Switches to secondary RPC endpoints upon transport failure.
