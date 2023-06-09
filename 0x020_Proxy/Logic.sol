// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Logic {

    event CallSuccess();

    address public implementation;
    uint public x = 99;

    /// @notice a function which simplely add one to x
    function addOne() external returns(uint) {
        emit CallSuccess();
        return x + 1;
    }
    
}