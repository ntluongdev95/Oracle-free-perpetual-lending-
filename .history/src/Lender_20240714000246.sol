// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
 
contract Lender is Ownable {


    struct Pool {
    address lender;
    address loanToken;
    address collateralToken;
    uint256 minLoanSize;
    /// @notice the maximum size of the loan (also equal to the balance of the lender)
    uint256 poolBalance;
    /// @notice the max ratio of loanToken/collateralToken (multiplied by 10**18)
    uint256 maxLoanRatio;
    /// @notice the length of a refinance auction
    uint256 auctionLength;
    /// @notice the interest rate per year in BIPs
    uint256 interestRate;
    /// @notice the outstanding loans this pool has
    uint256 outstandingLoans;
}

    constructor () Ownable(msg.sender){}



}