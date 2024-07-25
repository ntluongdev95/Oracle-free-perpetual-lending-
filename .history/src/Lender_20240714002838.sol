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
   struct Borrow {
    bytes32 poolId;
    /// @notice the amount to borrow
    uint256 debt;
    /// @notice the amount of collateral to put up
    uint256 collateral;
}

struct Loan {
    /// @notice address of the lender
    address lender;
    /// @notice address of the borrower
    address borrower;
    /// @notice address of the loan token
    address loanToken;
    /// @notice address of the collateral token
    address collateralToken;
    /// @notice the amount borrowed
    uint256 debt;
    /// @notice the amount of collateral locked in the loan
    uint256 collateral;
    /// @notice the interest rate of the loan per second (in debt tokens)
    uint256 interestRate;
    /// @notice the timestamp of the loan start
    uint256 startTimestamp;
    /// @notice the timestamp of a refinance auction start
    uint256 auctionStartTimestamp;
    /// @notice the refinance auction length
    uint256 auctionLength;
}


    constructor () Ownable(msg.sender){}



}