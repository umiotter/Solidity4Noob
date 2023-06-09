// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenLocker{

    event TokenLockStart(address indexed beneficiary, address indexed token, uint startTime, uint lockTime);
    event Release(address indexed beneficiary, address indexed token, uint releaseTime, uint amount);

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint public immutable lockTime;
    uint public immutable startTime;

    constructor(address _tokenaddr, address _beneficiary, uint _lockTime) {
        require(_lockTime > 0, "TokenLock: lock time should greater than 0");
        token = IERC20(_tokenaddr);
        beneficiary = _beneficiary;
        lockTime = _lockTime;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary, _tokenaddr, startTime, lockTime);
    }

    // @notice token transfer while reach release time
    function release() external {
        require(block.timestamp >= startTime + lockTime, "TokenLock: current time is before release time");

        // 注意Token和ETH的区别，该合约的Token数量由Token的合约决定，因此不
        // 是用address(this).balance查询剩余该合约地址所拥有的Token
        uint amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        
        token.transfer(beneficiary, amount);

        emit Release(beneficiary, address(token), startTime + lockTime, amount);
    }


}
