// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract UUPSLogicOld {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "Old";
    }

    function upgrade(address _newImplementation) public {
        require(msg.sender == admin, "UUPSLogic::upgrade: Only admin can upgrade.");
        implementation = _newImplementation;
    }
}

contract UUPSLogicNew {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "New";
    }

    function upgrade(address _newImplementation) public {
        require(msg.sender == admin, "UUPSLogic::upgrade: Only admin can upgrade.");
        implementation = _newImplementation;
    }

}