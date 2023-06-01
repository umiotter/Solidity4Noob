// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/// @notice sender is buyer, recipient is seller
/// ETH的发送者是买家接收者是卖家， 每次交易买家会把支票发送给卖家
/// 支票的金额是所有交易次数的金额的叠加，这样买家只需要使用最后一次的支票信息发送给合约
/// 兑现支票的金额。

contract PaymentChannel {
    // The account sending payments
    address payable public sender; 
    // The account receiving the payments
    address payable public recipient;
    // Timeout in case the recipient never closes
    uint256 public expiration;

    constructor (address payable _recipientAddress, uint256 _duration) public payable{
        sender = payable(msg.sender);
        recipient = _recipientAddress;
        expiration = block.timestamp + _duration;
    }


    function isValidSignature(uint256 _amount, bytes memory _signature) internal view returns(bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, _amount)));
        return recoverSigner(message, _signature) == sender;
    }

    /// @notice add prefix
    function prefixed(bytes32 _hash) internal pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /// @notice the recipient close the channe at any time by presenting a signed amout from the sender.
    /// @dev the recipient will be sent that amount, and the remainder will go back to the sender.
    function close(uint256 _amount, bytes32 memory _signature) external {
        require(msg.sender == recipient);
        require(isValidSignature(_amount, _signature));

        recipient.transfer(_amount);
        selfdestruct(sender);
    }

    /// @notice extend the expiration by sender
    function extend(uint256 _newExpiration) external{
        require(msg.sender == sender);
        require(_newExpiration > expiration);
        expiration = _newExpiration;
    }
    
    /// @notice while reach the expiration, the sender can close the channel and refund
    function claimTimeout() external {
        require(msg.sender == sender);
        require(block.timestamp > expiration);
        selfdestruct(sender);
    }

    /// @notice split signature to r s v
    function splitSignature(bytes memory sig) internal pure returns(uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    /// @notice recover signature signner address
    function recoverSigner(bytes32 _message, bytes memory _sig) internal pure returns(address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_sig);
        return ecrecover(_message, v, r, s);
    }


}