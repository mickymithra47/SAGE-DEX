// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IERC20Standard {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// Non-standard token that returns nothing on transfer (like USDT)
interface IERC20NoReturn {
    function transfer(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title MockFeeOnTransferToken
 * @notice Token that burns/takes 10% fee on every transfer
 */
contract MockFeeOnTransferToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public constant FEE_BPS = 1000; // 10%

    constructor(uint256 initial) {
        balanceOf[msg.sender] = initial;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 fee = (amount * FEE_BPS) / 10_000;
        uint256 received = amount - fee;

        require(balanceOf[from] >= amount, "Insufficient");
        balanceOf[from] -= amount;
        balanceOf[to] += received;
        return true;
    }
}

/**
 * @title MockNoReturnToken
 * @notice Token that does not return a boolean on transfer (violates ERC-20 standard)
 */
contract MockNoReturnToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 initial) {
        balanceOf[msg.sender] = initial;
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount;
    }

    function transferFrom(address from, address to, uint256 amount) external {
        require(balanceOf[from] >= amount, "Insufficient");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }
}

/**
 * @title WeirdTokenHandler
 * @notice Demonstrates safe token handling in AMMs/Vaults:
 *         1. SafeTransfer library handling non-standard returns via assembly
 *         2. Balance-delta accounting for fee-on-transfer tokens
 */
contract WeirdTokenHandler {
    error TransferFailed();

    mapping(address => uint256) public depositedAmount;

    // FLAGGED VULNERABLE: Assumes received amount == transferred amount
    function naiveDeposit(address token, uint256 amount) external {
        IERC20Standard(token).transferFrom(msg.sender, address(this), amount);
        depositedAmount[msg.sender] += amount; // Fails invariant if fee-on-transfer!
    }

    // SECURE: Uses balance delta to measure exact tokens credited to contract
    function secureDeposit(address token, uint256 amount) external returns (uint256 actualReceived) {
        uint256 balanceBefore = IERC20Standard(token).balanceOf(address(this));
        
        safeTransferFrom(token, msg.sender, address(this), amount);

        uint256 balanceAfter = IERC20Standard(token).balanceOf(address(this));
        actualReceived = balanceAfter - balanceBefore;

        depositedAmount[msg.sender] += actualReceived;
    }

    // Safe low-level transferFrom supporting standard and non-standard tokens
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(IERC20Standard.transferFrom.selector, from, to, amount);
        (bool success, bytes memory returndata) = token.call(data);

        if (!success || (returndata.length != 0 && !abi.decode(returndata, (bool)))) {
            revert TransferFailed();
        }
    }
}
