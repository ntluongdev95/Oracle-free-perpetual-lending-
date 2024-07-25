// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Lender} from "../src/Lender.sol";
import{DeployLender} from "../script/DeployLender.sol";
import{ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LenderTest is Test{

    Lender lender;
    IERC20Mock collateralToken;
    IERC20Mock loanToken;
    address public lender1 = address(0x1);
    address public lender2 = address(0x2);
    address public borrower = address(0x3);

    function setUp() public{
        DeployLender deploy = new DeployLender();
        lender = deploy.run();
        collateralToken = new ERC20Mock();
        loanToken = new ERC20Mock();
    }



}