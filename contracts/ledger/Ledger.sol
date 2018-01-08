pragma solidity ^0.4.18;

import '../modifiers/FromContract.sol';
import '../common/Destroyable.sol';

interface LedgerDataStorage {
    function getTransaction(uint256 _index) public view returns (address, address, uint256);

    function addTransaction(address _from, address _to, uint256 _tokens) external returns (bool success);

    function transactionsLength() public view returns (uint256);
}

contract Ledger is FromContract, Destroyable {

    LedgerDataStorage private ledgerDataStorage;

    function Ledger (address ledgerDataStorageAddress) public {
        require(ledgerDataStorageAddress != address(0));
        ledgerDataStorage = LedgerDataStorage(ledgerDataStorageAddress);
    }

    function addTransaction(address _from, address _to, uint256 _tokens) public fromContract returns (bool success) {
        require(ledgerDataStorage.addTransaction(_from, _to, _tokens));
        return true;
    }

    /**
    * The idea behind the two methods below is that the BOT
    * can get the last few transactions by getting the
    * transactions count (calling getTransactionsCount())
    * and calling getTransaction() method for each one of them.
    * This way we will keep the contract as simple as possible.
    */

    /**
   * @dev Allows the Bot to get a transcation by index.
   * @param _index is zero based and is the index in transactions mapping.
   * @return transaction's parameters' values.
   */
    function getTransaction(uint256 _index) public view returns (address, address, uint256) {
        return ledgerDataStorage.getTransaction(_index);
    }

    function getTransactionsCount() public view returns (uint256) {
        return ledgerDataStorage.transactionsLength();
    }
     
}