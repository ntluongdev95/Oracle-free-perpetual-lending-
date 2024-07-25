// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {Lender,Borrow,Pool} from "../src/Lender.sol";
import{DeployLender} from "../script/DeployLender.s.sol";
import{ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LenderTest is Test{

    Lender lender;
    ERC20Mock collateralToken;
    ERC20Mock loanToken;
    address public LENDER1 = makeAddr("lender1");
    address public LENDER2 = makeAddr("lender2");
    address public BORROWER = makeAddr("borrower");

    event PoolCreated(bytes32 indexed poolId, Lender.Pool pool);
    event PoolUpdated(bytes32 indexed poolId, Lender.Pool pool);
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
        vm.startPrank(LENDER1);
         loanToken.approve(address(lender),100000*10**18);
        Pool memory pool = Pool ({
            lender:address(lender),
            collateralToken:address(collateralToken),
            loanToken: address(loanToken),
            minLoanSize: 100*10**18,
            poolBalance: 1000*10**18,
            auctionLength: 1 days,
            outstandingLoans: 0,
            interestRate: 1000,
            maxLoanRatio: 8000
        });
        bytes32 poolId = lender.createPool(pool);
        vm.stopPrank();
        (,,,,uint256 poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 1000*10**18);    
    }

    function test_borrow() public{
         vm.startPrank(LENDER1);
         loanToken.approve(address(lender),100000*10**18);
        Pool memory pool = Pool ({
            lender:address(lender),
            collateralToken:address(collateralToken),
            loanToken: address(loanToken),
            minLoanSize: 100*10**18,
            poolBalance: 1000*10**18,
            auctionLength: 1 days,
            outstandingLoans: 0,
            interestRate: 1000,
            maxLoanRatio: 8000
        });
        bytes32 poolId = lender.createPool(pool);
        vm.stopPrank();
         (,,,,uint256 poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 1000*10**18); 

        vm.startPrank(BORROWER);
       Borrow memory borrow = Borrow({
            poolId: poolId,
            debt: 100*10**18,
            collateral: 100*10**18
        });
        Borrow[] memory borrows = new Borrow[](1);
        borrows[0] = borrow;
         lender.borrow(borrows);

        assertEq(loanToken.balanceOf(BORROWER), 995*10**17);
        assertEq(collateralToken.balanceOf(LENDER), 100*10**18);
        (,,,,poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 900*10**18);


    }



}