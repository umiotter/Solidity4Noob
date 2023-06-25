// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IERC20.sol';

/// @notice a faucet for umiotter token
/// @dev transfer token to this contract after deploied
contract UmiotterTokenFaucet{
    // each address allow request {amountAllowed} token one time.
    uint public amountAllowed = 100;
    address public tokenContract;
    mapping(address => bool) public requestAddress;

    event SendToken(address indexed Receiver, uint indexed Amount);

    constructor(address _tokenContract){
        tokenContract = _tokenContract;
    }

    function requestTokens() external{
        require(requestAddress[msg.sender] == false, "Can't request multiple times.");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty");
        token.transfer(msg.sender, amountAllowed);
        requestAddress[msg.sender] = true;

        emit SendToken(msg.sender, amountAllowed);
    }

}
