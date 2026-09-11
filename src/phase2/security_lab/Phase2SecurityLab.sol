// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../libraries/SafeTokenTransfer.sol";
import {TokenAccountingMath} from "../libraries/TokenAccountingMath.sol";

// ==========================================
// SCENARIO 1: ALLOWANCE MISUSE
// ==========================================
contract VulnerableAllowanceConsumer {
    mapping(address => uint256) public userBalances;

    // VULNERABILITY: Does not decrement or validate allowance on transferFrom!
    function deposit(address token, address from, uint256 amount) external {
        IERC20(token).transferFrom(from, address(this), amount);
        userBalances[from] += amount;
    }
}

contract SecureAllowanceConsumer {
    using SafeTokenTransfer for IERC20;
    mapping(address => uint256) public userBalances;

    function deposit(IERC20 token, address from, uint256 amount) external {
        token.safeTransferFrom(from, address(this), amount);
        userBalances[from] += amount;
    }
}

// ==========================================
// SCENARIO 2: APPROVAL RACE CONDITION
// ==========================================
contract VulnerableApprovalToken is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    uint256 public override totalSupply;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    // Standard vulnerable approve: subject to front-running race condition
    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        require(balanceOf[from] >= amount, "Insufficient");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

contract SecureApprovalHandler {
    using SafeTokenTransfer for IERC20;

    // Mitigates race condition by forcing allowance to 0 first if existing allowance is non-zero
    function safeApproveWithReset(IERC20 token, address spender, uint256 amount) external {
        token.safeApproveWithReset(spender, amount);
    }
}

// ==========================================
// SCENARIO 3: UNSAFE TRANSFER HANDLING
// ==========================================
contract VulnerableTransferHandler {
    // VULNERABILITY: Raw interface call ignores failure on non-reverting tokens
    function sendTokens(address token, address to, uint256 amount) external {
        IERC20(token).transfer(to, amount);
    }
}

contract SecureTransferHandler {
    using SafeTokenTransfer for IERC20;

    function sendTokens(IERC20 token, address to, uint256 amount) external {
        token.safeTransfer(to, amount);
    }
}

// ==========================================
// SCENARIO 4: FALSE-RETURN TOKEN HANDLING
// ==========================================
contract VulnerableFalseReturnRecipient {
    mapping(address => uint256) public balances;

    function deposit(address token, uint256 amount) external {
        // VULNERABILITY: Ignores boolean return value of transferFrom
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }
}

contract SecureFalseReturnRecipient {
    using SafeTokenTransfer for IERC20;
    mapping(address => uint256) public balances;

    function deposit(IERC20 token, uint256 amount) external {
        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }
}

// ==========================================
// SCENARIO 5: NO-RETURN TOKEN HANDLING (USDT)
// ==========================================
interface IStandardERC20Strict {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract VulnerableNoReturnConsumer {
    // VULNERABILITY: Strict Solidity interface expects 32-byte boolean return,
    // so it throws an EVM revert when interacting with USDT/No-return tokens!
    function transferStrict(address token, address to, uint256 amount) external returns (bool) {
        return IStandardERC20Strict(token).transfer(to, amount);
    }
}

contract SecureNoReturnConsumer {
    using SafeTokenTransfer for IERC20;

    function transferSafe(IERC20 token, address to, uint256 amount) external {
        token.safeTransfer(to, amount);
    }
}

// ==========================================
// SCENARIO 6: REENTRANT TOKEN EXPLOIT
// ==========================================
contract VulnerableVaultReentrancy {
    mapping(address => uint256) public deposits;

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(address token, uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");

        // VULNERABILITY: External call before state deduction!
        IERC20(token).transfer(msg.sender, amount);

        deposits[msg.sender] -= amount;
    }
}

contract SecureVaultReentrancy {
    using SafeTokenTransfer for IERC20;
    mapping(address => uint256) public deposits;
    uint256 private _locked = 1;

    modifier nonReentrant() {
        require(_locked == 1, "ReentrancyGuard");
        _locked = 2;
        _;
        _locked = 1;
    }

    function deposit(IERC20 token, uint256 amount) external nonReentrant {
        deposits[msg.sender] += amount;
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(IERC20 token, uint256 amount) external nonReentrant {
        require(deposits[msg.sender] >= amount, "Insufficient");

        // 1. Update state first (CEI)
        deposits[msg.sender] -= amount;

        // 2. Safe external call last
        token.safeTransfer(msg.sender, amount);
    }
}

// ==========================================
// SCENARIO 7: FEE-ON-TRANSFER MISMATCH
// ==========================================
contract VulnerableFeeOnTransferVault {
    mapping(address => uint256) public creditedBalance;

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        // VULNERABILITY: Assumes received amount == transfer amount!
        creditedBalance[msg.sender] += amount;
    }
}

contract SecureFeeOnTransferVault {
    using SafeTokenTransfer for IERC20;
    mapping(address => uint256) public creditedBalance;

    function deposit(IERC20 token, uint256 amount) external returns (uint256 actualReceived) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));

        actualReceived = balanceAfter - balanceBefore;
        creditedBalance[msg.sender] += actualReceived;
    }
}

// ==========================================
// SCENARIO 8: REBASING INCONSISTENCY
// ==========================================
contract VulnerableRebasingVault {
    mapping(address => uint256) public depositedRawAmount;

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        depositedRawAmount[msg.sender] += amount;
    }

    // VULNERABILITY: If token rebases down, contract cannot fulfill withdrawal!
    function withdraw(address token, uint256 amount) external {
        require(depositedRawAmount[msg.sender] >= amount, "Insufficient");
        depositedRawAmount[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
    }
}

contract SecureRebasingShareVault {
    using SafeTokenTransfer for IERC20;

    uint256 public totalShares;
    mapping(address => uint256) public userShares;

    function deposit(IERC20 token, uint256 amount) external returns (uint256 shares) {
        uint256 totalAssetsBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);

        if (totalShares == 0 || totalAssetsBefore == 0) {
            shares = amount;
        } else {
            shares = (amount * totalShares) / totalAssetsBefore;
        }

        totalShares += shares;
        userShares[msg.sender] += shares;
    }

    function withdraw(IERC20 token, uint256 shares) external returns (uint256 assets) {
        require(userShares[msg.sender] >= shares, "Insufficient shares");

        uint256 currentTotalAssets = token.balanceOf(address(this));
        assets = (shares * currentTotalAssets) / totalShares;

        userShares[msg.sender] -= shares;
        totalShares -= shares;

        token.safeTransfer(msg.sender, assets);
    }
}

// ==========================================
// SCENARIO 9: DECIMAL MISMATCH PRECISION
// ==========================================
contract VulnerableMultiDecimalSwap {
    // VULNERABILITY: 1:1 swap between tokens with different decimals (e.g. USDC 6 dec and DAI 18 dec)
    // causes 1 USDC (1e6) to only buy 0.000000000001 DAI (1e6 wei of DAI)!
    function swapNaive1to1(address tokenIn, address tokenOut, uint256 amountIn) external pure returns (uint256 amountOut) {
        amountOut = amountIn; // Bug: no decimal normalization!
    }
}

contract SecureMultiDecimalSwap {
    using TokenAccountingMath for uint256;

    function swapWithDecimalScaling(
        uint256 amountIn,
        uint8 decimalsIn,
        uint8 decimalsOut
    ) external pure returns (uint256 amountOut) {
        amountOut = TokenAccountingMath.scaleDecimals(amountIn, decimalsIn, decimalsOut);
    }
}

// ==========================================
// SCENARIO 10: SIGNATURE REPLAY ACROSS CONTRACTS
// ==========================================
contract VulnerablePermitNoContractAddress {
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowance;

    // VULNERABILITY: Digest does not bind address(this)!
    function permitVulnerable(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp <= deadline, "Expired");
        bytes32 digest = keccak256(abi.encode(owner, spender, value, nonces[owner]++, deadline));
        address signer = ecrecover(digest, v, r, s);
        require(signer == owner && signer != address(0), "Invalid");
        allowance[owner][spender] = value;
    }
}

contract SecurePermitWithDomainSeparator {
    bytes32 public immutable DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("SecurePermit"),
                keccak256("1"),
                block.chainid,
                address(this) // Binds verifyingContract!
            )
        );
    }

    function permitSecure(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp <= deadline, "Expired");
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signer = ecrecover(digest, v, r, s);
        require(signer == owner && signer != address(0), "Invalid");
        allowance[owner][spender] = value;
    }
}

// ==========================================
// SCENARIO 11: INVALID DOMAIN SEPARATOR (CROSS-CHAIN REPLAY)
// ==========================================
contract VulnerableStaticDomainPermit {
    bytes32 public immutable STATIC_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        // VULNERABILITY: Immutable domain separator cannot update on hard forks / chain ID changes!
        STATIC_DOMAIN_SEPARATOR = keccak256(
            abi.encode(keccak256("EIP712Domain(uint256 chainId)"), block.chainid)
        );
    }
}

contract SecureDynamicDomainPermit {
    bytes32 private immutable _INITIAL_DOMAIN_SEPARATOR;
    uint256 private immutable _INITIAL_CHAIN_ID;

    constructor() {
        _INITIAL_CHAIN_ID = block.chainid;
        _INITIAL_DOMAIN_SEPARATOR = _buildDomainSeparator(block.chainid);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        if (block.chainid == _INITIAL_CHAIN_ID) {
            return _INITIAL_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(block.chainid);
        }
    }

    function _buildDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(abi.encode(keccak256("EIP712Domain(uint256 chainId,address verifyingContract)"), chainId, address(this)));
    }
}

// ==========================================
// SCENARIO 12: NONCE REUSE EXPLOIT
// ==========================================
contract VulnerableNonceReusePermit {
    mapping(address => mapping(address => uint256)) public allowance;

    // VULNERABILITY: Nonce is not tracked or incremented, allowing identical signature replay!
    function permitNoNonce(
        address owner,
        address spender,
        uint256 value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(abi.encode(owner, spender, value));
        address signer = ecrecover(digest, v, r, s);
        require(signer == owner && signer != address(0), "Invalid");
        allowance[owner][spender] = value;
    }
}

contract SecureNonceTrackingPermit {
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowance;

    function permitWithNonce(
        address owner,
        address spender,
        uint256 value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Enforces strict one-time nonce consumption
        bytes32 digest = keccak256(abi.encode(owner, spender, value, nonces[owner]++));
        address signer = ecrecover(digest, v, r, s);
        require(signer == owner && signer != address(0), "Invalid");
        allowance[owner][spender] = value;
    }
}
