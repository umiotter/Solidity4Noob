// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract PaymentSplit{

    event PayeeAdded(address indexed account, uint indexed shares);
    event PaymentReleased(address indexed from, uint indexed amount);
    event PaymentReceived(address indexed from, uint indexed amount);

    uint public totalShares;
    uint public totalReleased;
    address[] public payees;
    mapping(address => uint) public shares;
    mapping(address => uint) public released;

    constructor(address[] memory _payees, uint[] memory _shares){
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch.");
        require(_payees.length > 0,"PaymentSplitter: no payees");
        for(uint i = 0; i < _payees.length; i++){
            _addPayee(_payees[i], _shares[i]);
        }
    }

    /// @notice add payee while initialize contract
    function _addPayee(address _payees, uint _shares) private {
        require(_payees != address(0), "PaymentSplitter: account is the zero address.");
        require(_shares > 0, "PaymentSplitter: shares are 0.");
        require(shares[_payees] == 0, "PaymentSplitter: account already has shares.");
        payees.push(_payees);
        shares[_payees] = _shares;
        totalShares += _shares;
        emit PayeeAdded(_payees, _shares);
    }

    receive() external payable virtual{
        emit PaymentReceived(msg.sender, msg.value);
    }

    /// @notice release shares to certain account
    function release(address _account) public virtual{
        require(shares[_account] > 0, "PaymentSplitter: account is not in shares or has no shares");
        uint _payment = releasable(_account);
        require(_payment > 0, "PaymentSplitter: account is not due payment");
        totalReleased += _payment;
        released[_account] += _payment;
        payable(_account).transfer(_payment);
        emit PaymentReleased(_account, _payment);
    }

    /// @notice calculate ETH which account can receive
    function releasable(address _account) public view returns(uint){
        uint _totalReceived = address(this).balance + totalReleased;
        uint _payment = _totalReceived * (shares[_account]/totalShares) - released[_account];
        return _payment;
    }

}