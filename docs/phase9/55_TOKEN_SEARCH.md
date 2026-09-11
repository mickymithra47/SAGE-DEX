# 55 — Token Search & Address Verification

## 1. Search Logic
1. **Exact Hex Address Match**: Highest priority; verified against on-chain contract code.
2. **Symbol Match**: Secondary lookup.
3. **Name Match**: Tertiary fuzzy search.
