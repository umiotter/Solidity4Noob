// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract digitalsignature{
    //**** packe massage and create signature ****//
     /// @notice get packed message
    function getMessageHash(address _account, uint256 _tokenId) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    /// @notice add prefix
    function prefixed(bytes32 _hash) internal pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    //**** unPacked signature and verify ****//
    /// @notice split signature to r s v
    function splitSignature(bytes memory sig) internal pure returns(uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65,"invalid signature length");

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

    /// @notice verify signature
    function verify(bytes32 _message, bytes memory _signature, address _signer) internal pure returns(bool){
        return recoverSigner(_message, _signature) == _signer;
    }


}