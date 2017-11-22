pragma solidity ^0.4.18;

contract EventsLog {

    struct Transaction {
        uint id;
        address from;
        address to;
        uint tokens;
    }

    mapping(uint => Transaction) public transactions;
    uint public nextTransactionId;
    address public owner;

    function EventsLog() public {
        nextTransactionId = 0;
        owner = msg.sender;
    }

    function saveTransaction(address _from, address _to, uint _tokens) public {
        var transaction = transactions[nextTransactionId];
        transaction.id = nextTransactionId;
        transaction.from = _from;
        transaction.to = _to;
        transaction.tokens = _tokens;
        nextTransactionId++;
    }

     
    // The idea behind the two methods below is that the BOT
    // can get the last few transactions by getting the
    // transactions count (calling getTransactionsCount())
    // and calling getTransaction() method for each one of them.
    // This way we will keep the contract as simple as possible.
 

    function getTransaction(uint _index) constant public returns (uint, address, address, uint) {
        return (transactions[_index].id, transactions[_index].from, transactions[_index].to, transactions[_index].tokens);
    }

    function getTransactionsCount() constant public returns (uint) {
        return nextTransactionId;
    }

    function destroy() public {
        selfdestruct(owner);
    }
}