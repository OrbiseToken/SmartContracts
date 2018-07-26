pragma solidity 0.4.24;

import './ERC20StandardData.sol';



/**
 * @title ERC20ExtendedData
 * @dev Contract that manages the data for ERC20Extended contract and allows modifying data only from it.
 */
contract ERC20ExtendedData is ERC20StandardData {
	mapping(address => bool) public frozenAccounts;

	/**
	 * @dev Function to freeze account to disable their interaction with the contract
	 * @param _target The target address to freeze
	 * @param _isFrozen Boolean value which is true for freezing and false for unfreezing
	 * @return success True if operation is successful
	 */
	function setFrozenAccount(address _target, bool _isFrozen) external fromContract returns (bool success) {
		frozenAccounts[_target] = _isFrozen;
		return true;
	}
}