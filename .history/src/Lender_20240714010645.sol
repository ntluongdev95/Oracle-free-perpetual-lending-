// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
 
contract Lender is Ownable {

    error FeeTooHigh();

    /// @notice the maximum interest rate is 1000%
    uint256 public constant MAX_INTEREST_RATE = 100000;
    /// @notice the maximum auction length is 3 days
    uint256 public constant MAX_AUCTION_LENGTH = 3 days;
    /// @notice the fee taken by the protocol in BIPs :1000 = 10%
    uint256 public lenderFee = 1000;
    /// @notice the fee taken by the protocol in BIPs : 50 = 0.5%
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
    
    mapping(bytes32 => Pool) public pools;
     Loan[] public loans;

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

    /////////Pool Info ///////// 
    function getPoolId (
        address lender,
        address loanToken,
        address collateralToken
    ) external pure returns (bytes32 poolId) {
        poolId = keccak256(abi.encode(lender, loanToken, collateralToken));
    }

    function getLoanDebt(uint256 loanId) external view returns (uint256 debt) {
        Loan memory loan = loans[loanId];
        (uint256 interest, uint256 fees) = _calculateInterest(loan);
        debt = loan.debt + interest + fees;
    }
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        BASIC LOANS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
     function createPool (Pool calldata p) external returns (bytes32 poolId) {

        if(p.
        
        )

     }


     /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         INTERNAL                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
     function _calculateInterest(
        Loan memory l
    ) internal view returns (uint256 interest, uint256 fees) {
        uint256 timeElapsed = block.timestamp - l.startTimestamp;
        interest = (l.interestRate * l.debt * timeElapsed) / 10000 / 365 days;
        fees = (lenderFee * interest) / 10000;
        interest -= fees;
    }



}