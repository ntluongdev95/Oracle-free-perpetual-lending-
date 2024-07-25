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
    LENDER1 = makeAddr("lender");
    LENDER2 = makeAddr("seller");
    BORROWER = makeAddr("arbiter");
    function setUp() public{
        DeployLender deploy = new DeployLender();
        lender = deploy.run();
        collateralToken = new ERC20Mock();
        loanToken = new ERC20Mock();
    }



}