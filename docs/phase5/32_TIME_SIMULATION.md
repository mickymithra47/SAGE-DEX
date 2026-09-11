# 32 — Time Simulation & Timestamp Granularity

## 1. Time Advancement Testing
Tested across diverse time scenarios:
1. **Same Block ($\Delta t = 0$)**: Cumulative price does not advance; instantaneous swaps exert zero weight on TWAP.
2. **Short Interval ($\Delta t = 10s$)**: Immediate responsiveness for short lookbacks.
3. **Standard Hour ($\Delta t = 3600s$)**: Verified exact TWAP convergence.
4. **Extended Inactivity ($\Delta t = 30 \text{ days}$)**: Tested that pending accumulation since `blockTimestampLast` integrates the entire inactivity interval seamlessly on next interaction.
