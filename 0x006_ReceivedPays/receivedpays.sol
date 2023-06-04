// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// 流程：
//     1. Sender建立合约， 附上要发送的ETH。
//     2. 用**私钥**生成一个签名。(签名包括收款人地址， 发送金额， nounce：交易次数，合约地址, hashed信息)
//     3. 发送签名信息给接收者（包括但不限于社交网络等）。
//     4. 接收者已知信息为：收款人地址，金额，nonce，合约地址；将以上信息联通发送者给的签名发送给合约，合约会释放ETH。


contract ReceiverPays{
    address owner = msg.sender;

    // record used nonces to prevent double using
    mapping(uint => bool) usedNonces;

    constructor() payable{}

    /// @notice receiver call this function with known information to get ETH
    function confirmPayment(uint _amount, uint _nounce, bytes memory _signature) external{
        require(!usedNonces[_nounce]);
        usedNonces[_nounce] = true;
        // reconstruct the signature prefix according to client information
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, _amount, _nounce, this)));
        // 
        require(recoverSigner(message, _signature) == owner);

        payable(msg.sender).transfer(_amount);
    }

    /// @notice contract selfdestruct 
    function kill() external{
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
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

    /// @notice recover signature signner
    function recoverSigner(bytes32 _message, bytes memory _sig) internal pure returns(address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_sig);
        return ecrecover(_message, v, r, s);
    }

    /// @notice add prefix
    function prefixed(bytes32 hash) internal pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }



}