
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TokenVesting{

    event ERC20Released(address indexed account, uint indexed amount);

    mapping(address => uint) public erc20Released; // record token type
    address public immutable beneficiary;
    uint public immutable start;
    uint public duration;


    constructor(address beneficiaryAddress, uint druationSeconds) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        duration = druationSeconds;
        start = block.timestamp;
    }

    function release(address _token) public {
        uint releasable = vestedAmount(_token, uint(block.timestamp)) - erc20Released[_token];
        erc20Released[_token] += releasable;
        emit ERC20Released(msg.sender, releasable);
    }

    function vestedAmount(address _token, uint timestamp) public returns(uint){

    }

}