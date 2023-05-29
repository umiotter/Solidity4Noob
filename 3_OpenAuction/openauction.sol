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
    event AcutionEnded(address winner, uint amount);

    error AcutionAlreadyEnded();
    error BidNotHighEnough(uint highestBidPrice);
    error AcutionNotYetEnded();
    error AuctionEndAlreadyCalled();

    /// @notice setting auctionEndTime and beneficiary address
    constructor(uint biddingTime, address payable beneficiaryAddress){
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    /// @notice bid a price
    function bid() external payable{
        if(block.timestamp > auctionEndTime){
            revert AcutionAlreadyEnded();
        }

        if(msg.value <= highestBidPrice){
            revert BidNotHighEnough(highestBidPrice);
        }

        // bid is higher than current highest bid,
        // save current higest bidder record for pending returns
        if(highestBidPrice != 0){
            pendingReturns[highestBidder] += highestBidPrice;
        }

        highestBidder = msg.sender;
        highestBidPrice = msg.value;
        emit HighestBidIncreased(highestBidder, highestBidPrice);
    }

    /// @notice bider should call withdraw to return their eth
    function withdraw() external returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            // preventing replay attack
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
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

}