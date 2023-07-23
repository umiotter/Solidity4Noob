// SPDX-License-Identifier: MIT
// by Umiotter
pragma solidity ^0.8.4;

import "./utils/introspection/IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "./utils/Address.sol";
import "./utils/Strings.sol";

contract ERC721Simple is IERC721, IERC721Metadata {
    //Address library contrains isContract() for judging if addres is a contract
    using Address for address;
    //String library contrains uint to string function
    using Strings for uint256;

    //token name {{IERC721Metadata}}
    string public override name;
    //token symbol {{IERC721Metadata}}
    string public override symbol;
    //tokenId to its owner
    mapping(uint => address) private _owners;
    //address to its tokenId amount
    mapping(address => uint) private _balances;
    //tokenId to its operation approvals address,
    //only one address is approval at a time
    mapping(uint => address) private _tokenApprovals;
    //owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /// @notice initial token name and symbol
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /// @notice from {{IERC721:ERC165}}, check if contract implements some interface
    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // function for _owner
    /// @notice query the owner according to tokenId
    function ownerOf(
        uint256 tokenId
    ) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    // function for _ balance
    /// @notice query the token amount of an address
    function balanceOf(address owner) public view override returns (uint) {
        require(owner != address(0), "owner can't be zero address");
        return _balances[owner];
    }

    // function for _owner and _balance
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    function _isApprovedOrOwner(
        address _owner,
        address _operator,
        uint _tokenId
    ) private view returns (bool) {
        // token 's owner or appovaled operator or get approvals for all token operator
        // can control token
        return (_operator == _owner ||
            _tokenApprovals[_tokenId] == _operator ||
            _operatorApprovals[_owner][_operator]);
    }

    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "not ERC721Receiver"
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        // isContract() in {{Address}}
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    /// @notice query if operator get approved to control a owner's all asset
    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /// @notice set approval to operator for control all tokens
    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice query the operator address of a token
    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        operator = _tokenApprovals[tokenId];
    }

    function _approve(address owner, address to, uint tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Transfer事件。条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

}
