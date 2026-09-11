# 35 — Cursor-Based Pagination & Scalability

## 1. Cursor Pagination Formulation
$$\text{Query}: \text{WHERE (block\_number, log\_index) } < (C_{\text{block}}, C_{\text{log}}) \text{ ORDER BY block\_number DESC, log\_index DESC LIMIT } K$$

- Eliminates performance degradation of `OFFSET N` on large tables.
- Guarantees deterministic, stable page scrolling without skipping or duplicating records during live block production.
