// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ==========================================
// TOKEN 1: REENTRANT TOKEN
// ==========================================
interface ITokenRecipient {
    function onTokenTransfer(address from, address to, uint256 amount) external;
}

contract MockReentrantToken {
    string public name = "Reentrant Token";
    string public symbol = "REENT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        // VULNERABILITY: Untrusted callback during transfer!
        if (to.code.length > 0) {
            try ITokenRecipient(to).onTokenTransfer(from, to, amount) {} catch {}
        }

        return true;
    }
}

// ==========================================
// TOKEN 2: FEE-ON-TRANSFER TOKEN
// ==========================================
contract MockFeeOnTransferToken {
    string public name = "Fee On Transfer Token";
    string public symbol = "FOT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public feeBps = 1000; // 10% fee

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient");
        uint256 fee = (amount * feeBps) / 10_000;
        uint256 netAmount = amount - fee;

        balanceOf[from] -= amount;
        balanceOf[to] += netAmount;
        balanceOf[address(0xDEAD)] += fee; // fee burn/collection
        return true;
    }
}

// ==========================================
// TOKEN 3: REBASING TOKEN
// ==========================================
contract MockRebasingToken {
    string public name = "Rebasing Token";
    string public symbol = "REBASE";
    uint8 public decimals = 18;

    uint256 private _totalShares;
    uint256 public rebaseMultiplier = 1e18; // 1.0x

    mapping(address => uint256) private _shares;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 initialSupply) {
        _totalShares = initialSupply;
        _shares[msg.sender] = initialSupply;
    }

    function totalSupply() external view returns (uint256) {
        return (_totalShares * rebaseMultiplier) / 1e18;
    }

    function balanceOf(address account) external view returns (uint256) {
        return (_shares[account] * rebaseMultiplier) / 1e18;
    }

    function rebase(uint256 newMultiplier) external {
        rebaseMultiplier = newMultiplier;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 sharesToTransfer = (amount * 1e18) / rebaseMultiplier;
        require(_shares[from] >= sharesToTransfer, "Insufficient");
        if (from != msg.sender && allowance[from][msg.sender] != type(uint256).max) {
            require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
            allowance[from][msg.sender] -= amount;
        }
        _shares[from] -= sharesToTransfer;
        _shares[to] += sharesToTransfer;
        return true;
    }
}

// ==========================================
// TOKEN 4: BLACKLIST TOKEN
// ==========================================
contract MockBlacklistToken {
    string public name = "Blacklist Token";
    string public symbol = "BLIST";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function setBlacklist(address target, bool status) external {
        isBlacklisted[target] = status;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(!isBlacklisted[msg.sender], "Sender blacklisted");
        require(!isBlacklisted[to], "Recipient blacklisted");
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// ==========================================
// TOKEN 5: PAUSABLE TOKEN
// ==========================================
contract MockPausableToken {
    string public name = "Pausable Token";
    string public symbol = "PAUSE";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    bool public isPaused;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function setPaused(bool _paused) external {
        isPaused = _paused;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(!isPaused, "Transfers paused");
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// ==========================================
// TOKEN 6: UNUSUAL DECIMALS TOKEN
// ==========================================
contract MockUnusualDecimalsToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _sym, uint8 _dec, uint256 _supply) {
        name = _name;
        symbol = _sym;
        decimals = _dec;
        totalSupply = _supply;
        balanceOf[msg.sender] = _supply;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// ==========================================
// TOKEN 7: FALSE RETURN TOKEN
// ==========================================
contract MockFalseReturnToken {
    string public name = "False Return Token";
    string public symbol = "FALSE";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (balanceOf[msg.sender] < amount) {
            return false; // Returns false instead of reverting!
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (balanceOf[from] < amount || allowance[from][msg.sender] < amount) {
            return false; // Returns false instead of reverting!
        }
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// ==========================================
// TOKEN 8: NO RETURN TOKEN (USDT STYLE)
// ==========================================
contract MockNoReturnToken {
    string public name = "No Return Token";
    string public symbol = "NORET";
    uint8 public decimals = 6;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount;
    }

    function transfer(address to, uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    function transferFrom(address from, address to, uint256 amount) external {
        require(balanceOf[from] >= amount, "Insufficient");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }
}

// ==========================================
// TOKEN 9: REVERTING TOKEN
// ==========================================
contract MockRevertingToken {
    string public name = "Reverting Token";
    string public symbol = "REVERT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = 1_000_000 ether;
    }

    function transfer(address, uint256) external pure returns (bool) {
        revert("Always Reverts");
    }

    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert("Always Reverts");
    }
}

// ==========================================
// TOKEN 10: MALICIOUS CALLBACK TOKEN
// ==========================================
contract MockMaliciousCallbackToken {
    string public name = "Malicious Callback Token";
    string public symbol = "CALLBACK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public attackTarget;
    bytes public attackPayload;

    mapping(address => uint256) public balanceOf;

    constructor(uint256 supply) {
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
    }

    function setAttackPayload(address target, bytes calldata payload) external {
        attackTarget = target;
        attackPayload = payload;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        if (attackTarget != address(0)) {
            attackTarget.call(attackPayload);
        }
        return true;
    }
}

// ==========================================
// TOKEN 11: TRANSFER RESTRICTION TOKEN
// ==========================================
contract MockTransferRestrictionToken {
    string public name = "Transfer Restriction Token";
    string public symbol = "RESTRICT";
    uint8 public decimals = 18;
    uint256 public maxTransferLimit = 1000 ether;

    mapping(address => uint256) public balanceOf;

    constructor(uint256 supply) {
        balanceOf[msg.sender] = supply;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(amount <= maxTransferLimit, "Exceeds max transfer limit");
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// ==========================================
// TOKEN 12: APPROVAL RACE TOKEN
// ==========================================
contract MockApprovalRaceToken {
    string public name = "Approval Race Token";
    string public symbol = "RACE";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 supply) {
        balanceOf[msg.sender] = supply;
    }

    // Vulnerable standard approve: allows spender to front-run allowance change
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        require(balanceOf[from] >= amount, "Insufficient balance");

        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}
