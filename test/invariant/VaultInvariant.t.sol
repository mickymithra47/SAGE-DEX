// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Project2_ERC20Token} from "../../src/05_mini_projects/Project2_ERC20Token.sol";
import {Project3_Vault} from "../../src/05_mini_projects/Project3_Vault.sol";

contract VaultHandler is Test {
    Project2_ERC20Token public immutable token;
    Project3_Vault public immutable vault;

    address[] public actors;
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;

    constructor(Project2_ERC20Token _token, Project3_Vault _vault) {
        token = _token;
        vault = _vault;

        actors.push(address(0x11111));
        actors.push(address(0x22222));
        actors.push(address(0x33333));
    }

    function fundActors() external {
        for (uint256 i = 0; i < actors.length; i++) {
            token.transfer(actors[i], 1_000_000 ether);
            vm.prank(actors[i]);
            token.approve(address(vault), type(uint256).max);
        }
    }

    function deposit(uint256 actorIndex, uint256 amount) external {
        actorIndex = actorIndex % actors.length;
        address actor = actors[actorIndex];
        amount = bound(amount, 1e6, 10_000 ether);

        vm.prank(actor);
        uint256 shares = vault.deposit(amount, actor);
        if (shares > 0) {
            totalDeposited += amount;
        }
    }

    function withdraw(uint256 actorIndex, uint256 shareFraction) external {
        actorIndex = actorIndex % actors.length;
        address actor = actors[actorIndex];

        uint256 userShares = vault.balanceOfShares(actor);
        if (userShares == 0) return;

        shareFraction = bound(shareFraction, 1, 100);
        uint256 sharesToWithdraw = (userShares * shareFraction) / 100;
        if (sharesToWithdraw == 0) return;

        vm.prank(actor);
        uint256 assetsReceived = vault.withdraw(sharesToWithdraw, actor, actor);
        totalWithdrawn += assetsReceived;
    }
}

contract VaultInvariantTest is Test {
    Project2_ERC20Token internal token;
    Project3_Vault internal vault;
    VaultHandler internal handler;

    function setUp() public {
        token = new Project2_ERC20Token("Invariant Token", "IVT", 18, 100_000_000 ether);
        vault = new Project3_Vault(token, "Invariant Vault", "vIVT");
        handler = new VaultHandler(token, vault);

        // Fund the handler so it can distribute tokens to actors
        token.transfer(address(handler), 10_000_000 ether);
        handler.fundActors();

        targetContract(address(handler));
    }

    // Invariant 1: Vault's asset balance must always equal or exceed the total accounted assets
    function invariant_VaultSolvency() public view {
        assertGe(
            token.balanceOf(address(vault)),
            vault.totalAssets(),
            "INVARIANT VIOLATED: Vault asset balance must match totalAssets()"
        );
    }

    // Invariant 2: Total withdrawn can never exceed total deposited
    function invariant_ConservationOfDeposits() public view {
        assertLe(
            handler.totalWithdrawn(),
            handler.totalDeposited(),
            "INVARIANT VIOLATED: Total withdrawn must never exceed total deposited"
        );
    }
}
