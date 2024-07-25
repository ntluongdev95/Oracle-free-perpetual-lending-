// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import { ERC20DecimalsMock } from "@openzeppelin/contracts/mocks/token/ERC20DecimalsMock.sol";

contract ERC20Mock is  ERC20DecimalsMock{
    constructor() {
        _mint(msg.sender, 1000000000000000000000000000);
    }
}