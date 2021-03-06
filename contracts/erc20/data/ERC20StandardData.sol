pragma solidity 0.4.24;

import '../../modifiers/FromContract.sol';


/**
 * @title ERC20StandardData
 * @dev Contract that manages the data for ERC20Standard contract and allows modifying data only from it.
 */
contract ERC20StandardData is FromContract {

	mapping(address => uint256) public balances;

	mapping(address => mapping (address => uint256)) public allowed;

	uint256 public totalSupply;

	/**
	 * @dev Function that sets the account's balance
	 * @param _owner The account which has its value set
	 * @param _value The value which is set
	 * @notice fromContract Modifier which allows only ERC20Standard to call this function
	 */
	function setBalance(address _owner, uint256 _value) external fromContract {
		balances[_owner] = _value;
	}

	/**
	 * @dev Function that sets the account's allowance
	 * @param _owner The account which is giving the allowance
	 * @param _spender The person which will be allowed to use the tokens of _owner 
	 * @param _amount The amount of tokens allowed to _spender
	 * @notice fromContract Modifier which allows only ERC20Standard to call this function
	 */
	function setAllowance(address _owner, address _spender, uint256 _amount) external fromContract {
		allowed[_owner][_spender] = _amount;
	}
	
	/**
	 * @dev Function that sets the contract's total supply of tokens
	 * @param _value The value to which total supply will be set
	 * @notice fromContract Modifier which allows only ERC20Standard to call this function
	 */
	function setTotalSupply(uint256 _value) external fromContract {
		totalSupply = _value;
	}

	/**
	 * @dev Function that increases the account's allowance
	 * @param _owner The account which is giving the allowance
	 * @param _spender The account which will be allowed to use the tokens of _owner 
	 * @param _increase The amount of tokens by which the allowance will increase
	 * @notice fromContract Modifier which allows only ERC20Standard to call this function
	 */
	function increaseAllowance(address _owner,  address _spender, uint256 _increase) external fromContract {
		allowed[_owner][_spender] = _add(allowed[_owner][_spender], _increase);
	}

	/**
	 * @dev Function that decreases the account's allowance
	 * @param _owner The account which is giving the allowance
	 * @param _spender The account which will be allowed to use the tokens of _owner 
	 * @param _decrease The amount of tokens by which the allowance will decrease
	 * @notice fromContract Modifier which allows only ERC20Standard to call this function
	 */
	function decreaseAllowance(address _owner,  address _spender, uint256 _decrease) external fromContract {
		allowed[_owner][_spender] = _sub(allowed[_owner][_spender], _decrease);
	}

	function _sub(uint256 _a, uint256 _b) private pure returns (uint256) {
		assert(_b <= _a);
		return _a - _b;
	}

	function _add(uint256 _a, uint256 _b) private pure returns (uint256) {
		uint256 c = _a + _b;
		assert(c >= _a);
		return c;
	}
}