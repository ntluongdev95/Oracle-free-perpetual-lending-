// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
 
contract Lender is Ownable {

    error FeeTooHigh();

    /// @notice the maximum interest rate is 1000%
    uint256 public constant MAX_INTEREST_RATE = 100000;
    /// @notice the maximum auction length is 3 days
    uint256 public constant MAX_AUCTION_LENGTH = 3 days;
    /// @notice the fee taken by the protocol in BIPs
    uint256 public lenderFee = 1000;
    /// @notice the fee taken by the protocol in BIPs
    uint256 public borrowerFee = 50;
    /// @notice the address of the fee receiver
    address public feeReceiver;


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
    uint256 debt;
    uint256 collateral;
}

struct Loan {
    address lender;
    address borrower;
    address loanToken;
    address collateralToken;
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


    constructor () Ownable(msg.sender){

         feeReceiver = msg.sender;
    }

    function setLenderFee(uint256 _fee) external onlyOwner {
        if (_fee > 5000) revert FeeTooHigh();
        lenderFee = _fee;
    }

    function setBorrowerFee(uint256 _fee) external onlyOwner {
        if (_fee > 500) revert FeeTooHigh();
        borrowerFee = _fee;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }




}