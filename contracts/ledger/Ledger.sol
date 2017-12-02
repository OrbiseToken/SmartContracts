pragma solidity ^0.4.18;

import '../modifiers/Ownable.sol';
import '../common/SafeMath.sol';
// import '../ledger/data/LedgerData.sol';

interface LedgerDataStorage {
    function getTransaction(uint _index) public view returns (uint, address, address, uint);
    function setTransaction(address _from, address _to, uint _tokens) external returns (bool);
    function getTransactionsLength() public view returns (uint256);
}

contract Ledger is Ownable {

    using SafeMath for uint256;
    LedgerDataStorage internal ledgerDataStorage;

    function Ledger (address ledgerDataStorageAddress) public {
        ledgerDataStorage = LedgerDataStorage(ledgerDataStorageAddress);
    }

    function addTransaction(address _from, address _to, uint _tokens) public onlyOwners returns (bool) {
        ledgerDataStorage.setTransaction(_from, _to, _tokens);
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