
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenVesting{

    event ERC20Released(address indexed account, uint indexed amount);

    mapping(address => uint) public erc20Released; // record token type
    address public immutable beneficiary;
    uint public immutable start;
    uint public duration;

    constructor(address beneficiaryAddress, uint druationSeconds) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        duration = druationSeconds;
        start = block.timestamp;
    }

    /// @notice releas token according to current timestamp
    function release(address _token) public {
        // 当前要发送的Token数量 = 当前时刻要发送的所有Token数量 - 当前时刻已记录的已发送的所有Token数量
        uint releasable = vestedAmount(_token, uint(block.timestamp)) - erc20Released[_token];
        // 记录并发送
        erc20Released[_token] += releasable;
        IERC20(_token).transfer(beneficiary,releasable);
        emit ERC20Released(msg.sender, releasable);
    }

    /// @notice calculate total vested amount
    function vestedAmount(address _token, uint _timestamp) public view returns(uint) {
        // 当前时刻要发送的所有Token数量
        uint totalAllocation = IERC20(_token).balanceOf(address(this)) + erc20Released[_token];
        
        if (_timestamp < start) { // 还未到归属期释放的开始事件
            return 0;
        } else if (_timestamp > start + duration) { // 如果过了归属期
            return totalAllocation;
        } else { // 如果仍在归属期中，计算从归属期开始到当前阶段需要释放的全部份额
            return (totalAllocation * (_timestamp - start)) / duration;
        }
    }

}