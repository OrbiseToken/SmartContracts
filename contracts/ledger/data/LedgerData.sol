pragma solidity 0.4.24;

import '../../modifiers/FromContract.sol';


contract LedgerData is FromContract {

	struct Transaction {
		address from;
		address to;
		uint256 tokens;
	}

	Transaction[] private transactions;

	function addTransaction(address _from, address _to, uint256 _tokens) external fromContract returns (bool success) {
		transactions.push(Transaction(_from, _to, _tokens));
		return true;
	}

	function getTransaction(uint256 _index) public view returns (address, address, uint256) {
		return (transactions[_index].from, transactions[_index].to, transactions[_index].tokens);
	}

	function transactionsLength() public view returns (uint256) {
		return transactions.length;
	}
}