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
    address public LENDER1 = makeAddr("lender1");
    address public LENDER2 = makeAddr("lender2");
    address public BORROWER = makeAddr("borrower");
    function setUp() public{
        DeployLender deploy = new DeployLender();
        lender = deploy.run();
        collateralToken = new ERC20Mock();
        loanToken = new ERC20Mock();
        collateralToken.mint(borrower,100000*10**18);
        loanToken.mint(lender1,100000*10**18);
        loanToken.mint(lender1,100000*10**18);
    }

    function testOwner () public {
        assertEq(lender.owner(), address(this));
    }



}