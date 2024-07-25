// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Lender} from "../src/Lender.sol";
import{DeployLender} from "../script/DeployLender.sol";

contract LenderTest is Test{

    Lender lender;
    IERC20Mock collateralToken;
    IERC20Mock loanToken;

    function setUp() public{

    }



}