// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library MerkleProof {
    /**
     * @param proof sorted merkle proof list (either descend or ascend is ok)
     * @param root root of merkle tree
     * @param leaf leaf node wait for validation
     * @return bool reconstruct root node hash sucess or not
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @param proof sorted merkle proof list
     * @param leaf hashed leaf node wait for validation
     * @return bytes32 root node hash
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    // Sorted Pair Hash
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}