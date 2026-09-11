# 32 — Off-Chain Reference Model & Solidity Parity

## 1. Reference Mathematical Model
To validate on-chain accounting without circular logic, an off-chain Python/Rust reference model simulates:

```python
def reference_initial_deposit(a0: int, a1: int) -> tuple[int, int]:
    initial = int(math.isqrt(a0 * a1))
    if initial <= 1000:
        raise ValueError("Insufficient")
    return initial - 1000, 1000

def reference_additional_deposit(a0: int, a1: int, r0: int, r1: int, total_s: int) -> int:
    s0 = (a0 * total_s) // r0
    s1 = (a1 * total_s) // r1
    return min(s0, s1)

def reference_redemption(burn_s: int, r0: int, r1: int, total_s: int) -> tuple[int, int]:
    return (burn_s * r0) // total_s, (burn_s * r1) // total_s
```

---

## 2. On-Chain Parity Verification
- Tested in `LPPositionMathTest` against Solidity execution.
- Outputs match the pure mathematical model down to exact integer wei with 0 discrepancy.
