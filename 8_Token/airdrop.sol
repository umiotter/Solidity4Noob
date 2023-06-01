// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './IERC20.sol';

contract Airdrop{
    function getSum(uint[] calldata _addr) public pure returns(uint sum){
        for(uint i = 0; i < _addr.length; i++){
            sum += _addr[i];
        }
    }

    /// @notice multi-transfer token from msg.sender to other address
    /// @dev this contract don't contain token
    function multiTransferToken(
        address _token, 
        address[] calldata _address, 
        uint[] calldata _amount
    ) external {
        require(_address.length == _amount.length, "Lengths of Addresses and Amounts NOT EQUAL");
        IERC20 token = IERC20(_token);
        uint _amountSum = getSum(_amount);
        require(token.allowance(msg.sender, address(this)) >= _amountSum, "Need Approve ERC20 token");
        for(uint8 i; i < _address.length; i++){
            token.transferFrom(msg.sender, _address[i], _amount[i]);
        }
    } 

    /// @notice multi-transfer ETH from msg.sender to other address
    /// @dev msg.sender should transfer enough ETH to this contract first
    function multiTransferETH(
        address payable[] calldata _address,
        uint[] calldata _amount
    ) public payable {
        require(_address.length == _amount.length);
        uint _amountSum = getSum(_amount);
        require(msg.value >= _amountSum, "You don't have enough ETH for airdrop");
        for(uint i = 0; i < _address.length; i++){
            _address[i].transfer(_amount[i]);
        }
    }

}