// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';

contract SimpleToken is IERC20 {
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;
    uint public override totalSupply;

    string public tokenName;
    string public tokenSymbol;

    address public owner;

    uint public decimals = 18;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;
        owner = msg.sender;
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }


    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        // 'msg.sender' approves 'spender' spend 'amount' asset
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice an simple example to mint token
    function mint(uint amount, address addr) external onlyOwner(){
        balanceOf[addr] += amount;
        totalSupply += amount;
        emit Transfer(address(0), addr, amount);
    }

    /// @notice an simple example to burn token
    function burn(uint amount) external{
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}