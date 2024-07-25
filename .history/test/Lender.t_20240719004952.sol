// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import  "../src/Lender.sol";
import{DeployLender} from "../script/DeployLender.s.sol";
import{ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import{ERC20DecimalsMock} from "@openzeppelin/contracts/mocks/token/ERC20DecimalsMock.sol";
import{ERC20Decimals} from "./ERC20Mock.t.sol";

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
        Lender.Pool memory pool = Lender.Pool ({
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
        Lender.Pool memory pool = Lender.Pool ({
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
         (,,,,uint256 poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 1000*10**18); 

        vm.startPrank(BORROWER);
        collateralToken.approve(address(lender),100000*10**18);
        Lender.Borrow memory borrow = Lender.Borrow({
            poolId: poolId,
            debt: 100*10**18,
            collateral: 100*10**18
        });
        Lender.Borrow[] memory borrows = new Lender.Borrow[](1);
        borrows[0] = borrow;
         lender.borrow(borrows);

        assertEq(loanToken.balanceOf(BORROWER), 995*10**17);
        assertEq(collateralToken.balanceOf(address(lender)), 100*10**18);
        (,,,,poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 900*10**18);
        (,,,,uint256 debt,,,,,) = lender.loans(0);
        console.log(debt);
    }
    function test_TokenHasDifferentDecimals() public{
        ERC20Decimals Loantoken = new ERC20Decimals(6,"LoanToken","LT");
        Loantoken.mint(LENDER1,100000*10**6);
        ERC20Decimals CollateralToken = new ERC20Decimals(18,"CollateralToken","CT");
        CollateralToken.mint(BORROWER,100000*10**18);
        
         vm.startPrank(LENDER1);
        Loantoken.approve(address(lender),100000*10**18);
        Lender.Pool memory pool = Lender.Pool ({
            lender:address(lender),
            collateralToken:address(CollateralToken),
            loanToken: address(Loantoken),
            minLoanSize: 100*10**6,
            poolBalance: 1000*10**6,
            auctionLength: 1 days,
            outstandingLoans: 0,
            interestRate: 1000,
            maxLoanRatio: 8000
        });
        bytes32 poolId = lender.createPool(pool);
         (,,,,uint256 poolBalance,,,,) = lender.pools(poolId);
        assertEq(poolBalance, 1000*10**6); 

        vm.startPrank(BORROWER);
        CollateralToken.approve(address(lender),100000*10**18);
        Lender.Borrow memory borrow = Lender.Borrow({
            poolId: poolId,
            debt: 100*10**6,
            collateral: 100*10**18
        });
        Lender.Borrow[] memory borrows = new Lender.Borrow[](1);
        borrows[0] = borrow;
         lender.borrow(borrows);

        //  assertEq(CollateralToken.balanceOf(address(lender)), 100*10**18);
         (,,,,poolBalance,,,,) = lender.pools(poolId);
       console.log(poolBalance);
        console.log(Loantoken.balanceOf(lender.feeReceiver()));

    }

    function test_repay () public {
        test_borrow();
         bytes32 poolId = keccak256(
            abi.encode(
                address(LENDER1),
                address(loanToken),
                address(collateralToken)
            )
        );
        vm.startPrank(BORROWER);

        uint256[] memory loanIds = new uint256[](1);
        loanIds[0] = 0;
        loanToken.mint(BORROWER,5*10**17);
        loanToken.approve(address(lender),1000*10**18);
        collateralToken.approve(address(BORROWER),100*10**18);
        vm.warp(3 days);
        console.log()
        lender.repay(loanIds);

        assertEq(loanToken.balanceOf(address(BORROWER)), 0);
        assertEq(collateralToken.balanceOf(address(lender)), 0);
       (,,,,uint256 poolBalance, ,uint256 outstandingLoans,,) = lender.pools(poolId);
        assertEq(poolBalance, 1000*10**18);
        console.log(outstandingLoans);
       
    }




}