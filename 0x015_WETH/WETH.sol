// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed addr, uint256 indexed value);
    event Withdraw(address indexed addr, uint256 indexed value);

    constructor() ERC20("WETH","WETH"){}

    fallback() external payable{
        deposit();
    }

    receive() external payable{
        deposit();
    }

    /// @notice deposit ETH and transfer to WETH
    function deposit() public payable{
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice withdraw ETH and burn equaled amount WETH
    function withdraw(uint amount) public{
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Deposit(msg.sender, amount);
    }
}