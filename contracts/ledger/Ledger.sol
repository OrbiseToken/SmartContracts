pragma solidity ^0.4.18;

import '../modifiers/Ownable.sol';
import '../common/SafeMath.sol';

interface LedgerDataStorage {
    function getTransaction(uint _index) public view returns (uint, address, address, uint);
    function setTransaction(address _from, address _to, uint _tokens) external returns (bool);
    function getTransactionsLength() public view returns (uint256);
    function setTransactionsLength(uint _value) external returns (bool);
}

contract Ledger is Ownable {

    using SafeMath for uint256;
    LedgerDataStorage internal ledgerDataStorage;

    function Ledger (address ledgerDataStorageAddress) public {
        ledgerDataStorage = LedgerDataStorage(ledgerDataStorageAddress);
    }

    function saveTransaction(address _from, address _to, uint _tokens) public onlyOwners returns (bool) {
        ledgerDataStorage.setTransaction(_from, _to, _tokens);
        uint transactionsLength = getTransactionsCount();
        transactionsLength = transactionsLength.add(1);
        ledgerDataStorage.setTransactionsLength(transactionsLength);
        return true;
    }

    // The idea behind the two methods below is that the BOT
    // can get the last few transactions by getting the
    // transactions count (calling getTransactionsCount())
    // and calling getTransaction() method for each one of them.
    // This way we will keep the contract as simple as possible.

    function getTransaction(uint _index) public view returns (uint, address, address, uint) {
        return ledgerDataStorage.getTransaction(_index);
    }

    function getTransactionsCount() public view returns (uint) {
        return ledgerDataStorage.getTransactionsLength();
    }

    function destroy() public onlyOwners returns (bool) {
        selfdestruct(msg.sender);
        return true;
    }
     

}