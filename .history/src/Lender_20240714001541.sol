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
    //if the max ratio is set to 
0.75
×
1
0
18
0.75×10 
18
  (which equals 0.75 when scaled down by 
1
0
18
10 
18
 ), it means you can borrow up to 75% of the value of your collateral.
    uint256 maxLoanRatio;
    /// @notice the length of a refinance auction
    uint256 auctionLength;
    /// @notice the interest rate per year in BIPs
    uint256 interestRate;
    uint256 outstandingLoans;
}

    constructor () Ownable(msg.sender){}



}