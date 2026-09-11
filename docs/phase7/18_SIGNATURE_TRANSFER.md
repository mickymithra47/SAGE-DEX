# 18 — Signature Transfer Pipeline: Direct Owner-to-Pair Forwarding

## 1. Zero-Intermediate-Hop Transfer
In `SagePermitRouter.swapExactTokensForTokensWithPermit2`:
- Router instructs `Permit2.permitTransferFrom` to deliver input tokens **directly into `_getPair(path[0], path[1])`**.
- Eliminates an intermediate transfer into the router, saving ~20,000 gas per swap.
