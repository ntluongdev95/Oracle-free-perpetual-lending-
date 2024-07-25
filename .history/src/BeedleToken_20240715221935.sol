// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BeedleToken is Ownable, ERC20, ERC20Votes,ERC20Permit {
    constructor() ERC20("Beedle", "BDL") ERC20Permit("BeedleToken") Ownable(msg.sender) {}

    // function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Votes) {
    //     super._afterTokenTransfer(from, to, amount);
    // }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount) internal  override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function nonces(address owner)  override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner); // You can call super to get the value from one of the base classes if they are the same
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
