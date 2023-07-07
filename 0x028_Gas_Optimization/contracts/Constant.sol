// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Constant {
    uint256 public constant varC = 1000;
    uint public immutable varI = 1000;
    uint public varV = 1000;

    constructor() {}

    function addVarC() external{
        varV = varC;
    }

    function addVarI() external {
        varV = varI;
    }

    function addVarV() external {
        varV = varV;
    }
}
