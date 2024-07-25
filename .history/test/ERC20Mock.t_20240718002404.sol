// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import { ERC20DecimalsMock } from "@openzeppelin/contracts/mocks/token/ERC20DecimalsMock.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Decimals is  ERC20DecimalsMock{
    constructor(uint8 decimals_,string memory name,string memory symbol) ERC20DecimalsMock(decimals_) ERC20(name,symbol) {
    }

    function decimals() public view override returns (uint8) {
        return super.decimals();
    }

     function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }



}