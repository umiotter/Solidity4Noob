// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract OpenAuction {
    // beneficiary will transfer some thing to highest bidder
    address payable public beneficiary;
    // auction end time
    uint public auctionEndTime;

    // current status
    address public highestBidder;
    uint public highestBidPrice;

    mapping(address => uint) pendingReturns;

    // label acution ending
    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event WithdrawSuccess(address addr, uint amount);
    event AcutionEnded(address winner, uint amount);

    error AcutionAlreadyEnded();
    error BidNotHighEnough(uint highestBidPrice);
    error AcutionNotYetEnded();
    error AuctionEndAlreadyCalled();

    /// @notice EN: setting auctionEndTime and beneficiary address
    constructor(uint _biddingTime, address payable _beneficiaryAddress){
        require(_beneficiaryAddress != address(0), "Beneficiary should not be zero address.");
        beneficiary = _beneficiaryAddress;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    /// @notice EN: bid a price
    function bid() external payable{
        // ensuring auction isnt ended
        if(block.timestamp > auctionEndTime){
            revert AcutionAlreadyEnded();
        }
        // ensuring bid price is higher than current highest price
        if(msg.value <= highestBidPrice){
            revert BidNotHighEnough(highestBidPrice);
        }

        // save previous highest bidder for pending returns
        if(highestBidPrice != 0){
            pendingReturns[highestBidder] += highestBidPrice;
        }

        highestBidder = msg.sender;
        highestBidPrice = msg.value;
        emit HighestBidIncreased(highestBidder, highestBidPrice);
    }

    /// @notice bider should call withdraw to return their eth
    function withdraw() external{
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0; // preventing reentrancy attack
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                revert();
            }
            emit WithdrawSuccess(msg.sender, amount);
        }
        else {
            revert();
        }
        
    } 

    /// @notice end the bid
    function auctionEnd() external{
        if(block.timestamp < auctionEndTime){
            revert AcutionNotYetEnded();
        }
        if(ended){
            revert AcutionAlreadyEnded();
        }

        ended = true;
        emit AcutionEnded(highestBidder, highestBidPrice);

        beneficiary.transfer(highestBidPrice);
    }

    fallback() external payable {}

    receive() external payable {}

}