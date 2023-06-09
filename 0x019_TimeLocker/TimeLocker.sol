// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TimeLocker{

    event QueueTransaction(
        bytes32 indexed txHash, 
        address indexed target, 
        uint value, 
        string signature,
        bytes data, 
        uint executeTime
    );
    event ExecuteTransaction(
        bytes32 indexed txHash, 
        address indexed target, 
        uint value, 
        string signature,
        bytes data, 
        uint executeTime
    );
    event CancelTranscation(
        bytes32 indexed txHash, 
        address indexed target, 
        uint value, 
        string signature,
        bytes data, 
        uint executeTime
    );
    event NewAdmin(address indexed adminAccount);   

    address public adminAccount; 
    uint public delay; // lock duration
    uint public constant GRACE_PERIOD = 7 days; // transation will expire after 7 days
    mapping (bytes32 => bool) public queuedTransactionDict; 

    constructor(uint _delay) {
        delay = _delay;
        adminAccount = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == adminAccount, "TimeLocker::Call must be admin.");
        _;
    }

    modifier onlyTimeLocker() {
        require(msg.sender == address(this), "TimeLocker:;Caller not Timelock.");
        _;
    }

    /// @notice change admin account
    /// @dev only this contract address can change admin account
    /// admin can design a transaction with changeAdmin(address) signature for admin changing
    function changeAdmin(address _newAdmin) public onlyTimeLocker {
        adminAccount = _newAdmin;
        emit NewAdmin(adminAccount);
    }

    /// @notice add a transcation into queue
    /// @dev admin should set a executeTime as query key, 
    /// executeTime must exceed locking delay
    function queueTransaction(
        address target, 
        uint value, 
        string memory signature, 
        bytes memory data, 
        uint executeTime
    ) public onlyOwner returns(bytes32) {
        require(executeTime >= block.timestamp + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // add transcation to queue list
        queuedTransactionDict[txHash] = true;
        // emit event
        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    /// @notice cancel transcation by owner
    function cancelTranscation(
        address target, 
        uint value, 
        string memory signature, 
        bytes memory data, 
        uint executeTime
    ) public onlyOwner {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        require(queuedTransactionDict[txHash],"Timelock::cancelTransaction: Transaction hasn't been queued.");
        queuedTransactionDict[txHash] = false;

        emit CancelTranscation(txHash, target, value, signature, data, executeTime);
    }

    /// @notice execute transaction
    function executeTransaction(
        address target, 
        uint value, 
        string memory signature, 
        bytes memory data, 
        uint executeTime
    ) public onlyOwner returns(bytes memory) {
        // get tx information
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // check whether tx has pass the lock time
        require(block.timestamp >= executeTime);
        // check whether tx expire
        require(block.timestamp <= executeTime + GRACE_PERIOD);
        // execute transaction by call function
        queuedTransactionDict[txHash] = false;
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");
        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }
    
    /// @notice pack and hash tx information
    function getTxHash(
        address target, 
        uint value, 
        string memory signature, 
        bytes memory data, 
        uint executeTime
    ) public pure returns(bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }
    
}