// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Unchecked {

    uint public res;

    function withoutUnckecked(uint256 times) external {
        uint result;
        for (uint256 i; i < times; i++) {
            result = i + 1;
        }

        res = result;
    }

    function withUnckecked(uint256 times) external {
        uint result;
        for (uint256 i; i < times; ) {
            unchecked {
                result = i + 1;
                i++;
            }
        }
        res = result;
    }

}