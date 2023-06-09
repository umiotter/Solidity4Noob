// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Caller {
    address public proxy;

    constructor(address _proxy) {
        proxy = _proxy;
    }

    /// @notice call proxy's addOne() function 
    function addOne() external returns(uint) {
        // abi.encodeWithSigure() achieve the selector of addOne() 
        // proxy.call() call function according to selector
        // the type of return resul is known as uint
        // abi.decode decode the return data to uint
        ( , bytes memory data) = proxy.call(abi.encodeWithSignature("addOne()"));
        return abi.decode(data,(uint));
    }

}