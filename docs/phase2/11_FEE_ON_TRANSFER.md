# 11 — Fee-on-Transfer Tokens & Balance-Delta Accounting

## 1. What are Fee-on-Transfer (FoT) Tokens?
Fee-on-transfer tokens deduct a percentage tax or burn fee whenever a transfer occurs:

$$\text{Recipient Balance Delta} = \text{Amount} \times (1 - \text{FeeBps})$$

For example, if Alice transfers 100 tokens with a 10% fee to a pool:
- Alice's balance decreases by 100.
- 10 tokens are burned or sent to a fee recipient.
- The pool's balance increases by only **90 tokens**.

---

## 2. The Naive Accounting Disaster
If an AMM executes:
```solidity
// VULNERABLE: Assumes pool received full amount!
token.transferFrom(msg.sender, address(this), 100);
uint256 amountOut = calculateAmountOut(100); // AMM gives out tokens based on 100!
```
The AMM credits 100 tokens of trade power while only receiving 90 tokens in reserve, causing reserve insolvency and trade mismatch.

---

## 3. The Balance-Delta Defensive Standard
To safely support fee-on-transfer tokens, always measure the physical balance delta:

```solidity
uint256 balanceBefore = token.balanceOf(address(this));
token.safeTransferFrom(msg.sender, address(this), amount);
uint256 balanceAfter = token.balanceOf(address(this));

uint256 actualReceived = balanceAfter - balanceBefore;
// Execute swap math strictly based on actualReceived!
```

---

## 4. Exact-Output Swaps Incompatibility
In an **Exact-Output swap** (where user specifies exact output tokens desired and computes required input):
- Fee-on-transfer tokens introduce recursive fee dependency ($input = \frac{netInput}{1 - fee}$).
- **Protocol Decision**: SAGE DEX will only support Fee-on-Transfer tokens on **Exact-Input swaps**, rejecting them from Exact-Output routes.
