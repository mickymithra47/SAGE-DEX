# 15 — Mathematical Derivation of Impermanent Loss

## 1. Defining Impermanent Loss
**Impermanent Loss (IL)** is the percentage difference in total portfolio value between holding tokens passively in a wallet versus depositing them into an AMM pool.

---

## 2. Derivation
Let initial price ratio be $P_0 = 1$ with initial reserves $(x_0, y_0)$.
Let price change by factor $r$ ($P_1 = r \cdot P_0$).
The pool rebalances to:
$$x_1 = \frac{\sqrt{k}}{\sqrt{r}} = \frac{x_0}{\sqrt{r}}$$
$$y_1 = \sqrt{k \cdot r} = y_0 \cdot \sqrt{r}$$

Value of LP portfolio:
$$V_{\text{LP}} = x_1 \cdot r + y_1 = \frac{x_0}{\sqrt{r}} \cdot r + y_0 \sqrt{r} = 2 \cdot y_0 \sqrt{r}$$

Value of HODL portfolio:
$$V_{\text{HODL}} = x_0 \cdot r + y_0 = y_0 \cdot (1 + r)$$

The ratio of LP value to HODL value is:
$$\frac{V_{\text{LP}}}{V_{\text{HODL}}} = \frac{2 \sqrt{r}}{1 + r}$$

$$\text{Impermanent Loss (IL)} = \frac{2 \sqrt{r}}{1 + r} - 1$$
