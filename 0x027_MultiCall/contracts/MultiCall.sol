// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MultiCall {
    // Call command structure
    struct Call {
        address target;
        bool allowFailure;
        bytes callData;
    }

    // Result structure
    struct Result {
        bool success;
        bytes returnData;
    }

    function multicall(
        Call[] calldata calls
    ) public returns (Result[] memory returnData) {
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata callInstance;

        // start multicall
        for (uint i = 0; i < length; i++) {
            Result memory result = returnData[i];
            callInstance = calls[i];
            
            (result.success, result.returnData) = callInstance.target.call(
                callInstance.callData
            );
            if (!(callInstance.allowFailure || result.success)) {
                revert("Multicall: call failed.");
            }
        }
    }
}
