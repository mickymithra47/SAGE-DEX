# 08 — Token Selection & Input Validation

## 1. Input Sanitization Rules
1. **Empty / Non-numeric**: Blocked from triggering RPC quotes.
2. **Negative Numbers**: Automatically rejected.
3. **Scientific Notation ($1e18$)**: Blocked to prevent integer parsing errors.
4. **Fractional Overflow**: Inputs with more decimal places than token decimals are rejected (`Too many decimal places`).
