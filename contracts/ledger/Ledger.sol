pragma solidity 0.4.24;

import '../modifiers/FromContract.sol';


contract Ledger is FromContract {

	struct Transaction {
		address from;
		address to;
		uint256 tokens;
	}

	Transaction[] public transactions;

	/**
	 * @dev Function that adds a transaction to the ledger transaction array
	 * @param _from The address of the origin of the transaction
	 * @param _to The address of the destination of the transaction
	 * @param _tokens The amount of tokens transferred
	 * @return success True if the operation was successful
	 */
	function addTransaction(address _from, address _to, uint256 _tokens) public fromContract returns (bool success) {
		transactions.push(Transaction(_from, _to, _tokens));
		return true;
	}

	/**
	 * @dev Function to get the length of the transaction array in the ledger
	 */
	function getTransactionsCount() public view returns (uint256) {
		return transactions.length;
	}
}