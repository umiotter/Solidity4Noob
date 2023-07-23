// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlindAuction{
    
    struct Bid {
        bytes32 blindedBid; // encrypted message
        uint deposit; // true bid value
    }

    address payable public beneficiary;
    uint public bidingEnd;
    uint public revealEnd;
    bool public ended;

    // bidder can bid multi-times, each blinded bid is hashed by 
    // `blindedBid` = keccak256(abi.encodePacked(uint value, bool fakeBid, bytes32 secret)).
    // each blinded bid can include eth.
    // bidder can use fake bid to confuse other competitors.
    // only the `fakeBid == false` bid is valid bid.
    // secret is a nounce given from bider.
    mapping(address => Bid[]) public bids;

    // information of current highest bid
    address highestBidder;
    uint highestBidPrice;

    // Allowed withdrawals of previous bids
    mapping(address => uint) public pendingReturns;

    event AuctionEnded(address winner, uint highestBidder);

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint _time){
        if(block.timestamp >= _time){
            revert TooLate(_time);
        }
        _;
    }

    modifier onlyAfter(uint _time){
        if(block.timestamp <= _time){
            revert TooEarly(_time);
        }
        _;
    }

    constructor(uint _biddingTime, uint _revealTime, address payable _beneficiaryAddress){
        bidingEnd = block.timestamp + _biddingTime;
        revealEnd = bidingEnd + _revealTime;
        beneficiary = _beneficiaryAddress;
    }
 
    /// @notice bid
    /// @param _blindedBid `blindedBid` = keccak256(abi.encodePacked(uint value, bool fakeBid, bytes32 secret))
    function bid(bytes32 _blindedBid) external payable{
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
    }

    /// @notice bidder reveals the blind bid
    /// @param _values bid price
    /// @param _fake bid is fake or not
    /// @param _secret nonce for blind bid
    /// @dev if a bidder dont reveal during reveal time, his/her eth will store in this contract permanently
    function reveal(
        uint[] calldata _values,
        bool[] calldata _fake,
        bytes32[] calldata _secret
    ) external 
    onlyAfter(bidingEnd)
    onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);
        
        uint refund;
        for(uint i = 0; i < length; i++){
            Bid storage bidOfSender = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            // check legitimacy of each bid
            if(bidOfSender.blindedBid != keccak256(abi.encodePacked(value, fake, secret))){
                continue;
            }

            refund += bidOfSender.deposit;
            // check if highest bid for true bid and if attached eth is enough
            // if not highest, refund
            if(!fake && bidOfSender.deposit >= value) {
                if(placeBid(msg.sender, value))
                    refund -= value;
            }
            bidOfSender.blindedBid = bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    /// @notice check the whether is highest bid price
    /// @param _bidder current bidder
    /// @param _value bid price
    function placeBid(address _bidder, uint _value) internal returns(bool success){
        // reject same highest bid price is invaild
        if(_value <= highestBidPrice){
            return false;
        }
        if(highestBidder != address(0)){
            // record previous highest bidder for refunding
            pendingReturns[highestBidder] += highestBidPrice;
        }
        highestBidder = _bidder;
        highestBidPrice = _value;
        return true;
    }

    /// @dev query balance in pendingReturns
    /// @return uint balance in pendingReturns
    function getPendingReturns() external view returns(uint) {
        return pendingReturns[msg.sender];
    }

    /// @notice bider should call withdraw to return their eth
    /// @return withdraw success or not
    /// @dev it‘s meaningless to call withdraw before reveal() 
    function withdraw() external returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// @notice end the auction, send the eth to beneficiary
    function auctionEnd() external onlyAfter(revealEnd){
        require(msg.sender == beneficiary);
        if (ended) revert AuctionEndAlreadyCalled();
        emit AuctionEnded(highestBidder, highestBidPrice);
        ended = true;
        beneficiary.transfer(highestBidPrice);
    }

}