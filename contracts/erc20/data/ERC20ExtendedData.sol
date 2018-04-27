pragma solidity 0.4.21;

import './ERC20StandardData.sol';



/**
 * @title ERC20ExtendedData
 * @dev Contract that manages the data for ERC20Extended contract and allows modifying data only from it.
 */
contract ERC20ExtendedData is ERC20StandardData {
	mapping(address => bool) public frozenAccounts;

	function setFrozenAccount(address _target, bool _isFrozen) external fromContract returns (bool success) {
		frozenAccounts[_target] = _isFrozen;
		return true;
	}
}