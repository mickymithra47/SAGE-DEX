# 07 — Safe Token Transfer Architecture (SafeERC20 Deep Dive)

## 1. Why SafeERC20 Wrappers Exist
`SafeTokenTransfer` provides an abstraction over raw token interactions that guarantees safe execution regardless of whether the target token adheres to standard boolean returns or non-standard USDT-style void returns.

---

## 2. Low-Level Assembly Architecture

```solidity
function _callOptionalReturn(address token, bytes memory data, bytes memory customError) private {
    if (token.code.length == 0) revert NonContractAddress(token);

    assembly {
        // Execute low-level call
        let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0)
        let returndata_size := returndatasize()

        // 1. Revert handling with error propagation
        if iszero(success) {
            if iszero(returndata_size) {
                revert(add(customError, 0x20), mload(customError))
            }
            returndatacopy(0x00, 0x00, returndata_size)
            revert(0x00, returndatasize())
        }

        // 2. Return data validation (USDT: 0 bytes OK; Standard: bool true OK, bool false REVERT)
        if gt(returndata_size, 0) {
            returndatacopy(0x00, 0x00, 0x20)
            let returnedVal := mload(0x00)
            if iszero(returnedVal) {
                revert(add(customError, 0x20), mload(customError))
            }
        }
    }
}
```

---

## 3. Comparison: Our SafeTokenTransfer vs OpenZeppelin SafeERC20

| Dimension | Our Implementation (`SafeTokenTransfer.sol`) | OpenZeppelin (`SafeERC20.sol`) |
| :--- | :--- | :--- |
| **Execution Layer** | Direct hand-tuned Yul assembly | High-level Solidity + `Address.functionCall` helper |
| **Error Handling** | Reverts with custom structured errors (`SafeTransferFailed`) | Reverts with string `"SafeERC20: low-level call failed"` |
| **Gas Efficiency** | Zero memory allocation overhead in happy path | Additional function call frames & memory buffers |
| **Contract Check** | Direct `extcodesize` check via `token.code.length` | `Address.isContract` validation |
