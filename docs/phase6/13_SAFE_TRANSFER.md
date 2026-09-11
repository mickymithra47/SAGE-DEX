# 13 — Safe Transfer Library & Low-Level Assembly

## 1. Yul Low-Level Call Pattern in `SafeTokenTransfer`
```solidity
assembly {
    let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0)
    let returndata_size := returndatasize()

    if iszero(success) {
        if iszero(returndata_size) {
            revert(add(customError, 0x20), mload(customError))
        }
        returndatacopy(0x00, 0x00, returndata_size)
        revert(0x00, returndatasize())
    }

    if gt(returndata_size, 0) {
        returndatacopy(0x00, 0x00, 0x20)
        let returnedVal := mload(0x00)
        if iszero(returnedVal) {
            revert(add(customError, 0x20), mload(customError))
        }
    }
}
```

- Robust against standard and non-standard ERC-20 token semantics.
