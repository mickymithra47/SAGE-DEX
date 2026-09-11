# 31 — Custom Error Definitions & Revert Taxonomy

## Custom Errors in `SageRouter`

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Custom Error                          │ Trigger Scenario                                       │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ Expired()                             │ block.timestamp > deadline                             │
│ InvalidPath()                         │ path.length < 2 or invalid boundary token for ETH swap │
│ InvalidRecipient()                    │ to == address(0) or to == address(this)                │
│ InsufficientOutput()                  │ amounts[last] < amountOutMin                           │
│ ExcessiveInput()                      │ amounts[0] > amountInMax                               │
│ PairNotFound()                        │ factory.getPair(tokenA, tokenB) returns address(0)     │
│ TransferFailed()                      │ Native ETH call transfer returned false                │
│ InsufficientETH()                     │ msg.value < required ETH input                         │
│ ZeroAddress()                         │ Constructor parameter address(0)                       │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```
