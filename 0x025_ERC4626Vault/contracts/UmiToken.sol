// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UmiToken is ERC20 {

    address public owner;

    constructor() ERC20("UmiToken", "UmiToken"){
        owner = msg.sender;
        mint(10000);
    }

    function mint(uint tokenNum) public {
        require(msg.sender == owner, "mint::Only owner can mint.");
        _mint(owner,tokenNum);
    }
}
