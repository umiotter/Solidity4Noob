// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/AmazingAng/WTFSolidity/blob/main/34_ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTOIN_SIZE = 10000; // NFT amount
    uint256 public constant AUCTION_START_PRICE = 1 ether; // start price (maximum price)
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // end price (lowest price)
    uint256 public constant AUCTION_TIME = 10 minutes; // auction duration
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; // price drop after interval
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); // price drop step
    
    uint256 public auctionStartTime; // auction start time
    string private _baseTokenURI;   // metadata URI
    uint256[] private _allTokens; // tokenIds

    constructor() ERC721("WTF Dutch Auctoin", "WTF Dutch Auctoin") {
        auctionStartTime = block.timestamp;
    }

    /// @notice auctionStartTime setter，onlyOwner can change
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    /// @notice get auction price according to block timestamp
    function getAuctionPrice()
        public
        view
        returns (uint256)
    {
        if (block.timestamp < auctionStartTime) {
        return AUCTION_START_PRICE;
        }else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
        return AUCTION_END_PRICE;
        } else {
        uint256 steps = (block.timestamp - auctionStartTime) /
            AUCTION_DROP_INTERVAL;
        return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function auctionMint(uint256 quantity) external payable{
        // for saving gas
        uint256 _saleStartTime = uint256(auctionStartTime);
        // check timestamp
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        );
        // check request quantity lower than supply
        require(
            totalSupply() + quantity <= COLLECTOIN_SIZE,
            "not enough remaining reserved for auction to support desired mint amount"
        );
        // calculate totalCost
        uint256 totalCost = getAuctionPrice() * quantity;
        require(msg.value >= totalCost, "Need to send more ETH.");

        // Mint NFT
        for(uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        // refund rest ETH
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost); //注意一下这里是否有重入的风险
        }
    }

}