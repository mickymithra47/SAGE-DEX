# 22 — Multi-LP Proportionate Fairness & Yield Verification

## 1. Multi-LP Scenario Model
In `MultiLPFairnessTest`:
- **Alice**: Deposits $1,000$ Token0 + $1,000$ Token1 ($\approx 10\%$ ownership).
- **Bob**: Deposits $2,000$ Token0 + $2,000$ Token1 ($\approx 20\%$ ownership).
- **Carol**: Deposits $7,000$ Token0 + $7,000$ Token1 ($\approx 70\%$ ownership).

---

## 2. Yield Distribution Parity
After executing trading volume generating swap fees:
- When all three LPs burn their LP shares:
  - Alice receives $1,000 + 10\% \text{ of fees}$.
  - Bob receives $2,000 + 20\% \text{ of fees}$ ($2\times \text{Alice's return}$).
  - Carol receives $7,000 + 70\% \text{ of fees}$ ($7\times \text{Alice's return}$).
- **Conclusion**: Fee yield is distributed strictly proportionally without front-running or diluting prior depositors.
