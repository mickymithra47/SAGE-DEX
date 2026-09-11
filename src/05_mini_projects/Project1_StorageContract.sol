// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Project1_StorageContract
 * @notice Mini-Project 1: Storage contract demonstrating storage optimization, events, and custom errors.
 */
contract Project1_StorageContract {
    // Custom Errors
    error Unauthorized(address caller);
    error InvalidAmount(uint256 amount);
    error ArrayOutOfBounds(uint256 requestedIndex, uint256 maxIndex);

    // Events with indexed topics (up to 3 indexed topics)
    event ConfigUpdated(address indexed updater, uint128 indexed newRate, uint64 indexed newPeriod);
    event EntryAdded(uint256 indexed id, address indexed user, uint256 amount);

    // Slot 0: Efficiently packed
    address public owner;     // 20 bytes
    uint64 public period;     // 8 bytes
    uint32 public threshold;  // 4 bytes (Total: 32 bytes)

    // Slot 1: Packed
    uint128 public rate;      // 16 bytes
    bool public isActive;     // 1 byte
    uint8 public mode;        // 1 byte (14 bytes free)

    // Slot 2: Mapping
    mapping(address => uint256) public userAmounts;

    // Slot 3: Dynamic array
    uint256[] public entries;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }
        _;
    }

    constructor(uint64 _period, uint32 _threshold, uint128 _rate) {
        owner = msg.sender;
        period = _period;
        threshold = _threshold;
        rate = _rate;
        isActive = true;
        mode = 1;
    }

    function updateConfig(uint128 _rate, uint64 _period, uint32 _threshold) external onlyOwner {
        rate = _rate;
        period = _period;
        threshold = _threshold;

        emit ConfigUpdated(msg.sender, _rate, _period);
    }

    function addEntry(uint256 amount) external {
        if (amount == 0) revert InvalidAmount(0);

        userAmounts[msg.sender] += amount;
        entries.push(amount);

        emit EntryAdded(entries.length - 1, msg.sender, amount);
    }

    function getEntry(uint256 index) external view returns (uint256) {
        if (index >= entries.length) {
            revert ArrayOutOfBounds(index, entries.length);
        }
        return entries[index];
    }

    function entriesCount() external view returns (uint256) {
        return entries.length;
    }
}
