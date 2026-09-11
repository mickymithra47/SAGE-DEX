# 18 — Recipient Security & Zero-Address Rejection

## 1. Recipient Boundary Checks
In all swap methods:
```solidity
if (to == address(0) || to == address(this)) revert InvalidRecipient();
```

---

## 2. Rationales
- **Rejecting `address(0)`**: Prevents accidental burn of user funds due to front-end misconfiguration.
- **Rejecting `address(this)`**: Prevents accidentally delivering output tokens into the router itself where they would become trapped.
