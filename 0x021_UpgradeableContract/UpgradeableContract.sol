// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract UpgradeableContract {
    address public implementation;
    address public adminAccount;
    string public words;

    constructor(address _implementation) {
        adminAccount = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        address _implementation = implementation;
        assembly {
            // copy msg.data to memory
            // msg.data length from 0 to calldatasize()
            calldatacopy(0, 0, calldatasize())
            // use gas() wei to delegate call {implementation} contract
            // the input memory position is from 0 to calldatasize()
            // the output memory posotion is from 0 to 0
            // call success or not will return bool value
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
            // copy return data to memory from position 0 to returndatasize()
            returndatacopy(0, 0, returndatasize())
            // further processing according to result
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
 
    function upgrade(address newImplementation) external {
        require(msg.sender == adminAccount);
        implementation = newImplementation;
    }

}