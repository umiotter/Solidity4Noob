// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CalldataAndMemory {
    struct Person {
        uint16 age;
        string name;
        string wish;
    }

    Person role_1;
    Person role_2;

    function writeByCalldata(Person calldata role_1_) external {
        role_1 = role_1_;
    }

    function writeByMemory(Person memory role_2_) external {
        role_2 = role_2_;
    }
}