// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultisigWallet {

    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public ownerCount;
    uint public threshold;
    uint public nonce;

    constructor(address[] memory _owners, uint _threshold) {
        _setupOwners(_owners, _threshold);
    }

    function _setupOwners(address[] memory _owners, uint _threshold) internal {
        require(threshold >= 1, "MultisigWallet::_setupOwners: Threshold must high than 1.");
        require(threshold <= owners.length, "MultisigWallet::_setupOwners: Owner amount is not enough.");

        for (uint i; i<_owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "MultisigWallet::_setupOwners: A candidate address is address(0)");
            require(owner != address(this), "MultisigWallet::_setupOwners: Owner can not be this contract.");
            require(!isOwner[owner], "MultisigWallet::_setupOwners: A candidate is owner.");
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    function execTransaction(
        address _to,
        uint _value,
        bytes memory _data,
        bytes memory _signatures
    ) 
        public payable virtual returns (bool success) {
        // encode transaction data
        bytes32 txHash = encodeTransactionData(_to, _value, _data, nonce, block.chainid);
        nonce++;
        // check the signagures
        checkSignatures(txHash, _signatures);
        // execute transaction
        (success, ) = _to.call{value: _value}(_data);
        require(success, "Transaction Success.");
        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    function encodeTransactionData(
        address _to,
        uint _value,
        bytes memory _data,
        uint _nonce,
        uint chainid
    ) public pure returns(bytes32) {
        return keccak256(
            abi.encode(_to, _value, keccak256(_data), _nonce, chainid)
        );
    }

    function checkSignatures(bytes32 _txHash, bytes memory _signatures) public view {
        require(_signatures.length >= threshold * 65, "");

        address lastOwner = address(0); 
        address currentOwner; 
        bytes32 r;
        bytes32 s;
        uint8 v;
        uint256 i;
        for (i = 0; i < threshold; i++) {
            (v, r, s) = signatureSplit(_signatures, i);
            // 利用ecrecover检查签名是否有效
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _txHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "WTF5007");
            lastOwner = currentOwner;
        }
    }

    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        // 签名的格式：{bytes32 r}{bytes32 s}{uint8 v}
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}