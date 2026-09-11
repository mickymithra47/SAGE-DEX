// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20, IERC20Metadata, IERC20Permit, IWETH} from "../interfaces/IERC20.sol";
import {SafeTokenTransfer} from "../libraries/SafeTokenTransfer.sol";
import {TokenAccountingMath} from "../libraries/TokenAccountingMath.sol";
import {TokenCompatibilityChecker} from "../libraries/TokenCompatibilityChecker.sol";

// ==========================================
// MINI PROJECT 1: MINIMAL ERC-20
// ==========================================
contract Project1_MinimalERC20 is IERC20 {
    string public name = "Minimal ERC20";
    string public symbol = "MIN";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Zero address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "Zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "Zero address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");

        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }
}

// ==========================================
// MINI PROJECT 2: ALLOWANCE ERC-20
// ==========================================
contract Project2_AllowanceERC20 is IERC20 {
    error InsufficientAllowance(address spender, uint256 current, uint256 required);
    error InsufficientBalance(address account, uint256 available, uint256 required);
    error ZeroAddress();

    string public name = "Allowance ERC20";
    string public symbol = "ALW";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        // Infinite allowance gas optimization (type(uint256).max avoids SSTORE)
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                revert InsufficientAllowance(msg.sender, currentAllowance, amount);
            }
            unchecked {
                allowance[from][msg.sender] = currentAllowance - amount;
            }
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }

        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        uint256 newAllowance = allowance[msg.sender][spender] + addedValue;
        allowance[msg.sender][spender] = newAllowance;
        emit Approval(msg.sender, spender, newAllowance);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        uint256 currentAllowance = allowance[msg.sender][spender];
        if (currentAllowance < subtractedValue) {
            revert InsufficientAllowance(spender, currentAllowance, subtractedValue);
        }
        unchecked {
            allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        }
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0) || to == address(0)) revert ZeroAddress();
        if (balanceOf[from] < amount) revert InsufficientBalance(from, balanceOf[from], amount);

        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }
}

// ==========================================
// MINI PROJECT 3: SAFE TRANSFER CONSUMER
// ==========================================
contract Project3_SafeTransferLib {
    using SafeTokenTransfer for IERC20;

    mapping(address => uint256) public deposits;

    function depositToken(IERC20 token, uint256 amount) external {
        // Uses SafeTokenTransfer to handle standard and non-standard tokens seamlessly
        token.safeTransferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function withdrawToken(IERC20 token, uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposit");
        deposits[msg.sender] -= amount;
        token.safeTransfer(msg.sender, amount);
    }
}

// ==========================================
// MINI PROJECT 4: WETH TOKEN
// ==========================================
contract Project4_WETHToken is IWETH, IERC20Metadata {
    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    receive() external payable {
        deposit();
    }

    function deposit() public payable override {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public override {
        require(balanceOf[msg.sender] >= wad, "Insufficient WETH balance");
        balanceOf[msg.sender] -= wad;
        totalSupply -= wad;

        emit Withdrawal(msg.sender, wad);
        emit Transfer(msg.sender, address(0), wad);

        (bool success, ) = msg.sender.call{value: wad}("");
        require(success, "ETH transfer failed");
    }

    function transfer(address dst, uint256 wad) external override returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function approve(address guy, uint256 wad) external override returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transferFrom(address src, address dst, uint256 wad) public override returns (bool) {
        require(balanceOf[src] >= wad, "Insufficient balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad, "Insufficient allowance");
            allowance[src][msg.sender] -= wad;
            emit Approval(src, msg.sender, allowance[src][msg.sender]);
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }
}

// ==========================================
// MINI PROJECT 5: EIP-2612 PERMIT TOKEN
// ==========================================
contract Project5_EIP2612Permit is IERC20, IERC20Permit {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public override totalSupply;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public override DOMAIN_SEPARATOR;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    mapping(address => uint256) public override nonces;

    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
            allowance[from][msg.sender] -= amount;
        }
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function permit(
        address ownerAccount,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(block.timestamp <= deadline, "Expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, ownerAccount, spender, value, nonces[ownerAccount]++, deadline)
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0) && signer == ownerAccount, "Invalid signer");

        allowance[ownerAccount][spender] = value;
        emit Approval(ownerAccount, spender, value);
    }
}

// ==========================================
// MINI PROJECT 6: ADVERSARIAL TOKEN LAB
// ==========================================
contract Project6_AdversarialLab {
    using SafeTokenTransfer for IERC20;

    mapping(address => mapping(address => uint256)) public userBalances;

    // Secure deposit that protects against reentrancy and measures balance deltas
    function depositSecure(IERC20 token, uint256 amount) external returns (uint256 actualCredited) {
        uint256 balBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balAfter = token.balanceOf(address(this));

        actualCredited = balAfter - balBefore;
        userBalances[address(token)][msg.sender] += actualCredited;
    }
}

// ==========================================
// MINI PROJECT 7: COMPATIBILITY CHECKER
// ==========================================
contract Project7_CompatibilityCheck {
    TokenCompatibilityChecker public checker;

    constructor() {
        checker = new TokenCompatibilityChecker();
    }

    function classify(address token, uint256 testAmount) external returns (TokenCompatibilityChecker.InspectionResult memory) {
        return checker.inspectToken(token, testAmount);
    }
}

// ==========================================
// MINI PROJECT 8: TOKEN ACCOUNTING LAB
// ==========================================
contract Project8_AccountingLab {
    using SafeTokenTransfer for IERC20;

    // Protocol Internal Accounting
    mapping(address => uint256) public internalReserves;

    event DonationDetected(address indexed token, uint256 excessAmount);
    event SyncExecuted(address indexed token, uint256 newReserve);

    // Sync function reconciles internal accounting with physical token balance
    function sync(IERC20 token) external returns (uint256 currentPhysicalBalance) {
        currentPhysicalBalance = token.balanceOf(address(this));
        uint256 previousInternal = internalReserves[address(token)];

        if (currentPhysicalBalance > previousInternal) {
            emit DonationDetected(address(token), currentPhysicalBalance - previousInternal);
        }

        internalReserves[address(token)] = currentPhysicalBalance;
        emit SyncExecuted(address(token), currentPhysicalBalance);
    }

    function swapDeposit(IERC20 token, uint256 amountIn) external returns (uint256 actualReceived) {
        uint256 balBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amountIn);
        uint256 balAfter = token.balanceOf(address(this));

        actualReceived = balAfter - balBefore;
        internalReserves[address(token)] += actualReceived;
    }
}
