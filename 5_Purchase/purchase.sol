// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract purchase{

    uint public price;
    address payable public seller;
    address payable public buyer;

    enum State {Created, Locked, Release, Inactive}

    State public state;

    event Abort();
    event PurchaseConfirmed();
    event ItemReceiveConfirmed();
    event SellerRefunded();

    error OnlySeller();
    error OnlyBuyer();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer(){
        require(msg.sender == buyer, "Only buyer can call this.");
        _;
    }

    modifier onlySeller(){
        require(msg.sender == seller, "Only seller can call this.");
        _;
    }

    modifier isState(State _state){
        require(state == _state, "Invalid state.");
        _;
    }

    /// @notice check if seller put even value in this sell contract
    /// @dev seller must put twice the value of the item as a guarantee fee 
    constructor() payable{
        seller = payable(msg.sender);
        price = msg.value/2;
        if((price * 2) != msg.value){
            revert ValueNotEven();
        }
    }

    /// @notice seller abort to sell item
    function abort() external onlySeller isState(State.Created){
        emit Abort();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    /// @notice buyer confirm purchasing item
    function confirmPurchase() external payable isState(State.Created){
        require(msg.value == (2*price));
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    /// @notice buyer confirm item has been received
    function confirmReceive() external onlyBuyer isState(State.Locked){
        emit ItemReceiveConfirmed();
        state = State.Release;
        buyer.transfer(price);
    }

    /// @notice seller get the triple price refund (guarantee fee + price)
    function refundSeller() external onlySeller isState(State.Release){
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3*price);
    }
}