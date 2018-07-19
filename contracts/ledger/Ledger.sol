pragma solidity 0.4.24;

import '../modifiers/FromContract.sol';

contract Ledger is FromContract {

	struct Transaction {
		address from;
		address to;
		uint256 tokens;
	}

	Transaction[] public transactions;

	function addTransaction(address _from, address _to, uint256 _tokens) public fromContract returns (bool success) {
		transactions.push(Transaction(_from, _to, _tokens));
		return true;
	}

	function getTransactionsCount() public view returns (uint256) {
		return transactions.length;
	}
}