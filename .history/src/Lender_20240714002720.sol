// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
 
contract Lender is Ownable {


    struct Pool {
    address lender;
    address loanToken;
    address collateralToken;
    uint256 minLoanSize;
    uint256 poolBalance;
    // how much you can borrow against your collateral.
    //if the max ratio is set to 0.75 it means you can borrow up to 75% of the value of your collateral.
    uint256 maxLoanRatio;
    uint256 auctionLength;
    uint256 interestRate;
    //refers to the total amount of active loans that have been issued by a particular pool and have not yet been repaid.
    uint256 outstandingLoans;
}

    constructor () Ownable(msg.sender){}



}