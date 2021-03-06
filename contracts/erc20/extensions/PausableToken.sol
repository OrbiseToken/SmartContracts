pragma solidity 0.4.24;

import '../ERC20Standard.sol';
import '../../modifiers/Pausable.sol';


/**
 * @title PausableToken
 * @dev ERC20Standard modified with pausable transfers.
 **/
contract PausableToken is ERC20Standard, Pausable {
	
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
		return super.approve(_spender, _value);
	}
}