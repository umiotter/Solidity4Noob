// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract UUPSProxy {
    address public implementation;
    address public adminAccount;
    string public words;

    constructor(address _implementation) {
        adminAccount = msg.sender;
        implementation = _implementation;
    } 

    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    receive() external payable {}
    
}