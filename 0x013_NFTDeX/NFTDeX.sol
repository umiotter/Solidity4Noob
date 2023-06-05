// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IERC721Receiver.sol";
import "./IERC721.sol";

contract NFTSwap is IERC721Receiver{
    event List(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newprice);

    event ReceiveToken(address indexed operator, address indexed from, uint256 indexed tokenId, bytes data);

    struct Order{
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable{}

    receive() external payable{}

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        emit ReceiveToken(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice put nft in store
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public{
        // ensure the nft token is belong to IERC721
        IERC721 _nft = IERC721(_nftAddr);
        //ensure the list list() is called by nft owner
        require(_nft.ownerOf(_tokenId) == msg.sender);
        // ensure the nft token has get approvaled
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");
        // ensure the price high than zero
        require(_price > 0);

        // pending orders
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;
        // nft in store
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // @notice update order
    function update(address _nftAddr, uint256 _tokenId, uint256 _price) public{
        require(_price > 0,"Price must higher than zero.");
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "NFT is not in DeX");

        _order.price = _price;

        emit Update(msg.sender, _nftAddr, _tokenId, _price);
    }

    // @notice revoke a nft from list
    function revoke(address _nftAddr, uint256 _tokenId) public{
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "NFT is not in DeX");

        // refund nft to seller
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // @notice purchase a NFT using ETH
    function purchase(address _nftAddr, uint256 _tokenId) payable public{
        Order storage _order = nftList[_nftAddr][_tokenId];
        // ensure the nft is in store.
        require(_order.price > 0, "Invalid Price");
        require(msg.value >= _order.price,"Increase price");
        IERC721 _nft = IERC721(_nftAddr);
        // ensure _nft is in DeX
        require(_nft.ownerOf(_tokenId) == address(this),"Invalid Price");

        // transfer NFT to the buyer
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // transfer and refund rest ETH
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        emit Purchase(msg.sender, _nftAddr, _tokenId, msg.value);
    }



}