// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20Token} from "./ERC20Token.sol";
import {IERC20Metadata} from "../interfaces/IERC20.sol";

/**
 * @title DecimalsToken
 * @notice Parameterized token for testing unusual decimals (0, 6, 8, 18, 30).
 */
contract DecimalsToken is ERC20Token {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) ERC20Token(_name, _symbol, _decimals, _initialSupply) {}
}

/**
 * @title TokenRegistry
 * @notice On-chain metadata and compatibility classification registry for the Sage protocol.
 *         Maintains verifiable metadata without displacing on-chain contract state as the ultimate source of truth.
 */
contract TokenRegistry {
    enum TokenCategory {
        Unknown,             // Unclassified
        CategoryA_Standard,  // Canonical standard ERC-20 (fully supported)
        CategoryB_NonStandard,// Missing boolean return / safe wrapper required
        CategoryC_FeeOnTransfer, // Deflationary / fee on transfer (requires balance delta handling)
        CategoryD_Rebasing,  // Dynamic elastic supply (requires special share vaults)
        CategoryE_Restricted,// Blacklist / pausable / transfer caps
        CategoryF_Unsupported// Reentrant / Malicious / Reverting
    }

    struct TokenMetadataRecord {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
        TokenCategory category;
        bool isVerified;
        uint256 registeredTimestamp;
    }

    error Unauthorized();
    error ZeroAddress();
    error AlreadyRegistered(address token);
    error TokenNotRegistered(address token);

    event TokenRegistered(address indexed token, string symbol, uint8 decimals, TokenCategory category);
    event TokenCategoryUpdated(address indexed token, TokenCategory previousCategory, TokenCategory newCategory);

    address public owner;
    mapping(address => TokenMetadataRecord) public tokens;
    address[] public registeredTokenList;

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerToken(
        address tokenAddress,
        TokenCategory category,
        bool isVerified
    ) external onlyOwner returns (bool) {
        if (tokenAddress == address(0)) revert ZeroAddress();
        if (tokens[tokenAddress].tokenAddress != address(0)) {
            revert AlreadyRegistered(tokenAddress);
        }

        string memory name = "UNKNOWN";
        string memory symbol = "UNK";
        uint8 decimals = 18;

        // Attempt on-chain query with low-level staticcall to avoid reverting on non-standard tokens
        try IERC20Metadata(tokenAddress).name() returns (string memory _name) {
            name = _name;
        } catch {}

        try IERC20Metadata(tokenAddress).symbol() returns (string memory _symbol) {
            symbol = _symbol;
        } catch {}

        try IERC20Metadata(tokenAddress).decimals() returns (uint8 _decimals) {
            decimals = _decimals;
        } catch {}

        tokens[tokenAddress] = TokenMetadataRecord({
            tokenAddress: tokenAddress,
            name: name,
            symbol: symbol,
            decimals: decimals,
            category: category,
            isVerified: isVerified,
            registeredTimestamp: block.timestamp
        });

        registeredTokenList.push(tokenAddress);
        emit TokenRegistered(tokenAddress, symbol, decimals, category);
        return true;
    }

    function updateCategory(address tokenAddress, TokenCategory newCategory) external onlyOwner {
        if (tokens[tokenAddress].tokenAddress == address(0)) {
            revert TokenNotRegistered(tokenAddress);
        }
        TokenCategory previous = tokens[tokenAddress].category;
        tokens[tokenAddress].category = newCategory;
        emit TokenCategoryUpdated(tokenAddress, previous, newCategory);
    }

    function getTokenCount() external view returns (uint256) {
        return registeredTokenList.length;
    }
}
