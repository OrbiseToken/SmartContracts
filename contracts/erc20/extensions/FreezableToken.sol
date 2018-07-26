pragma solidity 0.4.24;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';


/**
 * @title FreezableToken
 * @dev ERC20Standard modified with freezing accounts ability.
 */
contract FreezableToken is ERC20Standard, Ownable {

	event FrozenFunds(address indexed _target, bool _isFrozen);

	/**
	 * @dev Allow or prevent target address from sending & receiving tokens.
	 * @param _target Address to be frozen or unfrozen.
	 * @param _isFrozen Boolean indicating freeze or unfreeze operation.
	 */ 
	function freezeAccount(address _target, bool _isFrozen) public onlyOwners {
		require(_target != address(0), 'Non-zero to-be-frozen-account address required.');
		dataStorage.setFrozenAccount(_target, _isFrozen);
		emit FrozenFunds(_target, _isFrozen);
	}

	/**
	 * @dev Checks whether the target is frozen or not.
	 * @param _target Address to check.
	 * @return isFrozen A boolean that indicates whether the account is frozen or not. 
	 */
	function isAccountFrozen(address _target) public view returns (bool isFrozen) {
		return dataStorage.frozenAccounts(_target);
	}

	/**
	 * @dev Overrided _transfer function that uses freeze functionality
	 */
	function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
		assert(!dataStorage.frozenAccounts(_from));

		assert(!dataStorage.frozenAccounts(_to));
		
		return super._transfer(_from, _to, _value);
	}
}