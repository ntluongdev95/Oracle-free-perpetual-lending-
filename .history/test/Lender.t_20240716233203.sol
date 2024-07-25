// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {Lender} from "../src/Lender.sol";
import{DeployLender} from "../script/DeployLender.s.sol";
import{ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LenderTest is Test{

    Lender lender;
    ERC20Mock collateralToken;
    ERC20Mock loanToken;
    address public LENDER1 = makeAddr("lender1");
    address public LENDER2 = makeAddr("lender2");
    address public BORROWER = makeAddr("borrower");
    function setUp() public{
        DeployLender deploy = new DeployLender();
        lender = deploy.run();
        collateralToken = new ERC20Mock();
        loanToken = new ERC20Mock();
        collateralToken.mint(BORROWER,100000*10**18);
        loanToken.mint(LENDER1,100000*10**18);
        loanToken.mint(LENDER2,100000*10**18);
    }

    function testOwner() public {
        console.log(lender.owner());
        console.log(address(this));
    }

    function test_CreatePool () public{
        collateralToken.approve(address(lender),100000*10**18);
        vm.startPrank(LENDER1);
        Pool memory pool =Pool ({
            lender:address(lender),
            collateralToken:address(collateralToken),
            loanToken: addressloanToken,
            collateralAmount: 100000*10**18,
            loanAmount: 100000*10**18,
            interestRate: 10,
            duration: 100,
            status: 0,
            borrower: BORROWER,
            lender: LENDER1
        });
        })

    }



}