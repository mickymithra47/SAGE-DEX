# 12 — Spender Binding & Front-Running Immunity

## 1. Spender Binding Mechanics
In `Permit2.permitTransferFrom`, the message digest includes `msg.sender`:
```solidity
bytes32 dataHash = keccak256(
    abi.encode(
        PERMIT_TRANSFER_FROM_TYPEHASH,
        tokenPermissionsHash,
        msg.sender, // Spender strictly bound to caller
        nonce,
        deadline
    )
);
```

---

## 2. Security Result
- If an attacker intercepts the signature in the public mempool and tries to call `permitTransferFrom` directly to steal the tokens, the recovered signer changes and the transaction reverts with `InvalidSignature()`.
