# 13 — Oracle Subsystem Architecture & Manipulation Threat Model

## 1. Why Spot Price is an Insecure Oracle
Using instantaneous spot price ($\frac{\text{reserve1}}{\text{reserve0}}$) as an on-chain price feed is catastrophic:
- An attacker can borrow millions via flash loans, trade into the pool to distort the spot price by 10x, exploit a dependent lending/liquidation protocol, and repay the flash loan in the same block.

---

## 2. The Solution: Time-Weighted Average Price (TWAP)
- Time-weighting averages price over an extended time interval (e.g. 30 minutes or 1 hour).
- Flash loans operate within a single block ($\Delta t = 0$), exerting **0 weight** on the cumulative time-weighted average.
