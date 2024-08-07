// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import { ERC20DecimalsMock } from "@openzeppelin/contracts/mocks/token/ERC20DecimalsMock.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is  ERC20DecimalsMock{
    constructor(uint8 decimals_,string name,string symbol) ERC20DecimalsMock(decimals_) ERC20(name,) {
    }
}