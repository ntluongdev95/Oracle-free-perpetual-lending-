// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Lender is Ownable {
    error FeeTooHigh();
    error PoolConfig();
    error Unauthorized();
    error  LoanTooSmall();
    error LoanTooLarge();
    error RatioTooHigh();
    error  ZeroCollateral();
    error TokenMismatch();
    error RateTooHigh();
    error AuctionTooShort();
    error PoolTooSmall();

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

    event PoolCreated(bytes32 indexed poolId, Pool pool);
    event PoolUpdated(bytes32 indexed poolId, Pool pool);
    event PoolBalanceUpdated(bytes32 indexed poolId, uint256 newBalance);
      event PoolInterestRateUpdated(
        bytes32 indexed poolId,
        uint256 newInterestRate
    );
    event PoolMaxLoanRatioUpdated(
        bytes32 indexed poolId,
        uint256 newMaxLoanRatio
    );
    event Borrowed(
        address indexed borrower,
        address indexed lender,
        uint256 indexed loanId,
        uint256 debt,
        uint256 collateral,
        uint256 interestRate,
        uint256 startTimestamp
    );

     event Repaid(
        address indexed borrower,
        address indexed lender,
        uint256 indexed loanId,
        uint256 debt,
        uint256 collateral,
        uint256 interestRate,
        uint256 startTimestamp
    );
    event AuctionStart(
        address indexed borrower,
        address indexed lender,
        uint256 indexed loanId,
        uint256 debt,
        uint256 collateral,
        uint256 auctionStartTime,
        uint256 auctionLength
    );
    event LoanBought(uint256 loanId);
    event LoanSiezed(
        address indexed borrower,
        address indexed lender,
        uint256 indexed loanId,
        uint256 collateral
    );
    event Refinanced(uint256 loanId);

    //////////---------//////////

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

    constructor() Ownable(msg.sender) {
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
    function getPoolId(address lender, address loanToken, address collateralToken)
        public
        pure
        returns (bytes32 poolId)
    {
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

    function createPool(Pool calldata p) external returns (bytes32 poolId) {
        if (
            p.lender == address(0) || p.minLoanSize == 0 || p.maxLoanRatio == 0 || p.auctionLength == 0
                || p.interestRate == 0 || p.poolBalance == 0 || p.auctionLength > MAX_AUCTION_LENGTH
                || p.interestRate > MAX_INTEREST_RATE
        ) revert PoolConfig();
        poolId = getPoolId(p.lender, p.loanToken, p.collateralToken);
        if (p.outstandingLoans != pools[poolId].outstandingLoans) {
            revert PoolConfig();
        }
        uint256 currentBalance = pools[poolId].poolBalance;

        if (p.poolBalance > currentBalance) {
            // if new balance > current balance then transfer the difference from the lender
           bool success = IERC20(p.loanToken).transferFrom(msg.sender, address(this), p.poolBalance - currentBalance);
           require (success, "Transfer failed");
        } else if (p.poolBalance < currentBalance) {
            // if new balance < current balance then transfer the difference back to the lender
             bool success = IERC20(p.loanToken).transfer(p.lender, currentBalance - p.poolBalance);
                require (success, "Transfer failed");
        }
        emit PoolBalanceUpdated(poolId, p.poolBalance);

        if (pools[poolId].lender == address(0)) {
            // if the pool doesn't exist then create it
            emit PoolCreated(poolId, p);
        } else {
            // if the pool does exist then update it
            emit PoolUpdated(poolId, p);
        }

        pools[poolId] = p;
    }

    function addToPool(bytes32 poolId, uint256 amount) external {
        if (pools[poolId].lender != msg.sender) revert Unauthorized();
        if (amount == 0) revert PoolConfig();
        _updatePoolBalance(poolId, pools[poolId].poolBalance + amount);
        // transfer the loan tokens from the lender to the contract
        bool success = IERC20(pools[poolId].loanToken).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
    }

     function removeFromPool(bytes32 poolId, uint256 amount) external {
        if (pools[poolId].lender != msg.sender) revert Unauthorized();
        if (amount == 0) revert PoolConfig();
        _updatePoolBalance(poolId, pools[poolId].poolBalance - amount);
        // transfer the loan tokens from the contract to the lender
         bool success = IERC20(pools[poolId].loanToken).transfer(msg.sender, amount);
         require(success, "Transfer failed");
    }

     function updateMaxLoanRatio(bytes32 poolId, uint256 maxLoanRatio) external {
        if (pools[poolId].lender != msg.sender) revert Unauthorized();
        if (maxLoanRatio == 0) revert PoolConfig();
        pools[poolId].maxLoanRatio = maxLoanRatio;
        emit PoolMaxLoanRatioUpdated(poolId, maxLoanRatio);
    }

    function updateInterestRate(bytes32 poolId, uint256 interestRate) external {
        if (pools[poolId].lender != msg.sender) revert Unauthorized();
        if (interestRate > MAX_INTEREST_RATE) revert PoolConfig();
        pools[poolId].interestRate = interestRate;
        emit PoolInterestRateUpdated(poolId, interestRate);
    }

    function borrow(Borrow[] calldata borrows) public {
        for (uint256 i = 0; i < borrows.length; i++) {
            bytes32 poolId = borrows[i].poolId;
            uint256 debt = borrows[i].debt;
            uint256 collateral = borrows[i].collateral;
            // get the pool info
            Pool memory pool = pools[poolId];
            // make sure the pool exists
            if (pool.lender == address(0)) revert PoolConfig();
            // validate the loan
            if (debt < pool.minLoanSize) revert LoanTooSmall();
            if (debt > pool.poolBalance) revert LoanTooLarge();
            if (collateral == 0) revert ZeroCollateral();
            // make sure the user isn't borrowing too much
            uint256 loanRatio = (debt * 10 ** 18) / collateral;
            if (loanRatio > pool.maxLoanRatio) revert RatioTooHigh();
            // create the loan
            Loan memory loan = Loan({
                lender: pool.lender,
                borrower: msg.sender,
                loanToken: pool.loanToken,
                collateralToken: pool.collateralToken,
                debt: debt,
                collateral: collateral,
                interestRate: pool.interestRate,
                startTimestamp: block.timestamp,
                auctionStartTimestamp: type(uint256).max,
                auctionLength: pool.auctionLength
            });
            // update the pool balance
            _updatePoolBalance(poolId, pools[poolId].poolBalance - debt);
            pools[poolId].outstandingLoans += debt;
            // calculate the fees
            uint256 fees = (debt * borrowerFee) / 10000;
            // transfer fees
            bool success = IERC20(loan.loanToken).transfer(feeReceiver, fees);
            require(success, "Transfer failed");
            // transfer the loan tokens from the pool to the borrower
            bool successTransfer =IERC20(loan.loanToken).transfer(msg.sender, debt - fees);
            require(successTransfer, "Transfer failed");
            // transfer the collateral tokens from the borrower to the contract
            bool successTranferFrom = IERC20(loan.collateralToken).transferFrom(
                msg.sender,
                address(this),
                collateral
            );
            require(successTranferFrom, "Transfer failed");
            loans.push(loan);
            emit Borrowed(
                msg.sender,
                pool.lender,
                loans.length - 1,
                debt,
                collateral,
                pool.interestRate,
                block.timestamp
            );
        }
    }
     function repay(uint256[] calldata loanIds) public {
        for (uint256 i = 0; i < loanIds.length; i++) {
            uint256 loanId = loanIds[i];
            // get the loan info
            Loan memory loan = loans[loanId];
            // calculate the interest
            (
                uint256 lenderInterest,
                uint256 protocolInterest
            ) = _calculateInterest(loan);

            bytes32 poolId = getPoolId(
                loan.lender,
                loan.loanToken,
                loan.collateralToken
            );

            // update the pool balance
            _updatePoolBalance(
                poolId,
                pools[poolId].poolBalance + loan.debt + lenderInterest
            );
            pools[poolId].outstandingLoans -= loan.debt;

            // transfer the loan tokens from the borrower to the pool
            bool success = IERC20(loan.loanToken).transferFrom(
                msg.sender,
                address(this),
                loan.debt + lenderInterest
            );
            require(success, "Transfer failed");
            // transfer the protocol fee to the fee receiver
            bool success1 = IERC20(loan.loanToken).transferFrom(
                msg.sender,
                feeReceiver,
                protocolInterest
            );
            require(success1, "Transfer failed");
            // transfer the collateral tokens from the contract to the borrower
             bool success2 = IERC20(loan.collateralToken).transfer(
                loan.borrower,
                loan.collateral
            );
            require (success2, "Transfer failed");
            emit Repaid(
                msg.sender,
                loan.lender,
                loanId,
                loan.debt,
                loan.collateral,
                loan.interestRate,
                loan.startTimestamp
            );
            // delete the loan
            delete loans[loanId];
        }
    }

     /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         REFINANCE                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

     function giveLoan(
        uint256[] calldata loanIds,
        bytes32[] calldata poolIds
    ) external {
        for (uint256 i = 0; i < loanIds.length; i++) {
            uint256 loanId = loanIds[i];
            bytes32 poolId = poolIds[i];
            // get the loan info
            Loan memory loan = loans[loanId];
            // validate the loan
            if (msg.sender != loan.lender) revert Unauthorized();
            // get the pool info
            Pool memory pool = pools[poolId];
            // validate the new loan
            if (pool.loanToken != loan.loanToken) revert TokenMismatch();
            if (pool.collateralToken != loan.collateralToken)
                revert TokenMismatch();
            // new interest rate cannot be higher than old interest rate
            if (pool.interestRate > loan.interestRate) revert RateTooHigh();
            // auction length cannot be shorter than old auction length
            if (pool.auctionLength < loan.auctionLength) revert AuctionTooShort();
            // calculate the interest
            (
                uint256 lenderInterest,
                uint256 protocolInterest
            ) = _calculateInterest(loan);
            uint256 totalDebt = loan.debt + lenderInterest + protocolInterest;
            if (pool.poolBalance < totalDebt) revert PoolTooSmall();
            if (totalDebt < pool.minLoanSize) revert LoanTooSmall();
            uint256 loanRatio = (totalDebt * 10 ** 18) / loan.collateral;
            if (loanRatio > pool.maxLoanRatio) revert RatioTooHigh();
            // update the pool balance of the new lender
            _updatePoolBalance(poolId, pool.poolBalance - totalDebt);
            pools[poolId].outstandingLoans += totalDebt;

            // update the pool balance of the old lender
            bytes32 oldPoolId = getPoolId(
                loan.lender,
                loan.loanToken,
                loan.collateralToken
            );
            _updatePoolBalance(
                oldPoolId,
                pools[oldPoolId].poolBalance + loan.debt + lenderInterest
            );
            pools[oldPoolId].outstandingLoans -= loan.debt;

            // transfer the protocol fee to the governance
            bool sucess =IERC20(loan.loanToken).transfer(feeReceiver, protocolInterest);

            emit Repaid(
                loan.borrower,
                loan.lender,
                loanId,
                loan.debt + lenderInterest + protocolInterest,
                loan.collateral,
                loan.interestRate,
                loan.startTimestamp
            );

            // update the loan with the new info
            loans[loanId].lender = pool.lender;
            loans[loanId].interestRate = pool.interestRate;
            loans[loanId].startTimestamp = block.timestamp;
            loans[loanId].auctionStartTimestamp = type(uint256).max;
            loans[loanId].debt = totalDebt;

            emit Borrowed(
                loan.borrower,
                pool.lender,
                loanId,
                loans[loanId].debt,
                loans[loanId].collateral,
                pool.interestRate,
                block.timestamp
            );
        }
    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         INTERNAL                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function _calculateInterest(Loan memory l) internal view returns (uint256 interest, uint256 fees) {
        uint256 timeElapsed = block.timestamp - l.startTimestamp;
        interest = (l.interestRate * l.debt * timeElapsed) / 10000 / 365 days;
        fees = (lenderFee * interest) / 10000;
        interest -= fees;
    }

    function _updatePoolBalance(bytes32 poolId, uint256 newBalance) internal {
        pools[poolId].poolBalance = newBalance;
        emit PoolBalanceUpdated(poolId, newBalance);
    }
}
