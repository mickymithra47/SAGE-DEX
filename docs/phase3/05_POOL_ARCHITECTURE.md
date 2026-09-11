# 05 — Pool Storage Layout, Variable Packing & Mutex

## 1. Storage Layout & Packing Optimization

```
┌─────────┬─────────────────────────────────────────────────────────────────────────────┐
│ Slot #  │ Variables Packed in 32-Byte Slot                                            │
├─────────┼─────────────────────────────────────────────────────────────────────────────┤
│ Slot 0  │ address factory (20 bytes) | uint96 unused                                  │
│ Slot 1  │ address token0 (20 bytes)  | uint96 unused                                  │
│ Slot 2  │ address token1 (20 bytes)  | uint96 unused                                  │
│ Slot 3  │ uint112 reserve0 (14B) | uint112 reserve1 (14B) | uint32 timestampLast (4B) │
│ Slot 4  │ uint256 price0CumulativeLast (32 bytes)                                     │
│ Slot 5  │ uint256 price1CumulativeLast (32 bytes)                                     │
│ Slot 6  │ uint256 kLast (32 bytes)                                                    │
│ Slot 7  │ uint256 unlocked (32 bytes reentrancy mutex)                                │
└─────────┴─────────────────────────────────────────────────────────────────────────────┘
```

### Why Pack `reserve0`, `reserve1`, and `blockTimestampLast` into a Single Slot?
1. In EVM execution, loading a cold storage slot costs **2,100 gas** (`SLOAD`).
2. By packing both 112-bit reserves and the 32-bit block timestamp into **Slot 3**, a single `SLOAD` fetches all reserve state simultaneously for swap, mint, and burn execution.
3. `uint112` can store up to $2^{112} - 1 \approx 5.19 \times 10^{33}$ wei ($\approx 5.19 \times 10^{15}$ units of an 18-decimal token), rendering overflow impossible for all real-world assets.

---

## 2. Low-Level Reentrancy Mutex
The `lock` modifier enforces a non-reentrant state transition:
```solidity
modifier lock() {
    if (unlocked != 1) revert Locked();
    unlocked = 0;
    _;
    unlocked = 1;
}
```
This protects optimistic transfers, flash swaps, and arbitrary callbacks against state corruption.
