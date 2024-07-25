// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import { ERC20DecimalsMock}

contract ERC20Mock is  ERC20DecimalsMock{
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1000000000000000000000000000);
    }
}