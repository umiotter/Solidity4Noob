// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;
import "../lib/safemath.sol";

/// @title Voting Contrast
/// @author umiotter
/// @notice a voting demo
contract Voting {

    using SafeMath for uint256;

    // choose saving
    bytes32[] public candidateList;
    // record project name and received votes.
    mapping(bytes32 => uint256) public votesReceived;
    
    /// @notice initial the candidateList
    constructor( bytes32[] memory candidateNames ) public {
        candidateList = candidateNames;
    }

    /// @notice checking the candidate that user voted is validate or not.
    /// @param candidate the candidate that user voted.
    /// @return bool validation or not.
    function validCandiate(bytes32 candidate) view public returns(bool) {
        for(uint i = 0; i < candidateList.length; i++){
            if(candidateList[i] == candidate){
                return true;
            }
        }
        return false;
    }

    /// @notice vote a candidate.
    /// @param candidate the candidate that user voted.
    function addVote(bytes32 candidate) public {
        require(validCandiate(candidate));
        votesReceived[candidate] = votesReceived[candidate].add(1);
    }

    /// @notice query of the current amount of candidate user voted.
    /// @param candidate the candidate that user voted.
    /// @return uint8 current amount that user voted.
    function queryCurrentVotes(bytes32 candidate) public view returns(uint256){
        require(validCandiate(candidate));
        return votesReceived[candidate];
    }

}