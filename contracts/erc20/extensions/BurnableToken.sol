pragma solidity 0.4.24;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';


/**
 * @title BurnableToken
 * @dev ERC20Standard token that can be irreversibly burned(destroyed).
 */
contract BurnableToken is ERC20Standard, Ownable {

	event Burn(address indexed _burner, uint256 _value);
	
	/**
	 * @dev Remove tokens from the system irreversibly.
	 * @notice Destroy tokens from your account.
	 * @param _value The amount of tokens to burn.
	 */
	function burn(uint256 _value) public returns (bool success) {
		uint256 senderBalance = dataStorage.balances(msg.sender);
		require(senderBalance >= _value, "Burn value less than account balance required.");
		senderBalance = senderBalance.sub(_value);
		assert(dataStorage.setBalance(msg.sender, senderBalance));

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.sub(_value);
		assert(dataStorage.setTotalSupply(totalSupply));

		emit Burn(msg.sender, _value);

		emit Transfer(msg.sender, address(0), _value);

		return true;
	}

	/**
	 * @dev Remove specified `_value` tokens from the system irreversibly on behalf of `_from`.
	 * @param _from The address from which to burn tokens.
	 * @param _value The amount of money to burn.
	 */
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		uint256 fromBalance = dataStorage.balances(_from);
		require(fromBalance >= _value, "Burn value less than from-account balance required.");

		uint256 allowed = dataStorage.allowed(_from, msg.sender);
		require(allowed >= _value, "Burn value less than account allowance required.");

		fromBalance = fromBalance.sub(_value);
		assert(dataStorage.setBalance(_from, fromBalance));

		allowed = allowed.sub(_value);
		assert(dataStorage.setAllowance(_from, msg.sender, allowed));

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.sub(_value);
		assert(dataStorage.setTotalSupply(totalSupply));

		emit Burn(_from, _value);

		emit Transfer(_from, address(0), _value);

		return true;
	}
}