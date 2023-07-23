// SPDX-License-Identifier: MIT
// by Umiotter
pragma solidity ^0.8.4;

import "./ERC721/ERC721Simple.sol";

contract SimpleAPE is ERC721Simple{
    uint public MAX_APES = 10000; 

    constructor(string memory name_, string memory symbol_) ERC721Simple(name_, symbol_){
    }
    
    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_APES, "tokenId out of range");
        _mint(to, tokenId);
    }
}