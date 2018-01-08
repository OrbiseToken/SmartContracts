pragma solidity ^0.4.18;

import '../../modifiers/FromContract.sol';
import '../../common/SafeMath.sol';

contract LedgerData is FromContract {

    using SafeMath for uint256;

    struct Transaction {
        address from;
        address to;
        uint256 tokens;
    }

    mapping(uint256 => Transaction) private transactions;

    uint256 public transactionsLength = 0;

    function getTransaction(uint256 _index) public view returns (address, address, uint256) {
        return (transactions[_index].from, transactions[_index].to, transactions[_index].tokens);
    }

    function addTransaction(address _from, address _to, uint256 _tokens) external fromContract returns (bool success) {
        Transaction storage transaction = transactions[transactionsLength];
        transaction.from = _from;
        transaction.to = _to;
        transaction.tokens = _tokens;
        transactionsLength = transactionsLength.add(1);
        return true;
    }
}