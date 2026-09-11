# 04 — Direct Token Transfers: Execution & Edge Cases

## 1. Direct Transfer Semantics
The `transfer(address to, uint256 amount)` method executes a direct transfer of token units from `msg.sender` to the designated recipient address.

---

## 2. Core Execution Invariants
1. **Zero Address Protection**: Must reject `to == address(0)` to prevent permanent accidental burning of tokens.
2. **Balance Sufficiency**: `balanceOf[msg.sender] >= amount`.
3. **Supply Invariance**: `totalSupply` remains unchanged; `balanceOf[msg.sender]` decreases by `amount`, and `balanceOf[to]` increases by `amount`.
4. **Self-Transfer Edge Case**: When `to == msg.sender`, the net balance remains unchanged.
5. **Zero Amount Edge Case**: Transferring `0` tokens must succeed and emit a valid `Transfer(msg.sender, to, 0)` event without reverting.

---

## 3. Storage Mutation Breakdown
```
Before:
  balanceOf[Alice] = 1000
  balanceOf[Bob]   = 200

Transaction: Alice.transfer(Bob, 300)

Step 1: Check balance (SLOAD Slot[Alice] >= 300)
Step 2: Mutate Alice (SSTORE Slot[Alice] = 700)
Step 3: Mutate Bob   (SSTORE Slot[Bob]   = 500)
Step 4: Emit Event   (LOG3: Transfer(Alice, Bob, 300))
```
