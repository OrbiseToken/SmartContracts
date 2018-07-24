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

	function setBalance(address _owner, uint256 _value) external fromContract returns (bool success) {
		balances[_owner] = _value;
		return true;
	}

	function setAllowance(address _owner, address _spender, uint256 _amount) external fromContract returns (bool success) {
		allowed[_owner][_spender] = _amount;
		return true;
	}

	function setTotalSupply(uint256 _value) external fromContract returns (bool success) {
		totalSupply = _value;
		return true;
	}

	function increaseAllowance(address _owner,  address _spender, uint256 _increase) external fromContract returns (bool success) {
		allowed[_owner][_spender] = _add(allowed[_owner][_spender], _increase);
		return true;
	}


	function decreaseAllowance(address _owner,  address _spender, uint256 _decrease) external fromContract returns (bool success) {
		allowed[_owner][_spender] = _sub(allowed[_owner][_spender], _decrease);
		return true;
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