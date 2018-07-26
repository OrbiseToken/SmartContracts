pragma solidity 0.4.24;

import '../common/SafeMath.sol';

interface EternalDataStorage {
	function balances(address _owner) external view returns (uint256);

	function setBalance(address _owner, uint256 _value) external;

	function allowed(address _owner, address _spender) external view returns (uint256);

	function setAllowance(address _owner, address _spender, uint256 _amount) external;

	function totalSupply() external view returns (uint256);

	function setTotalSupply(uint256 _value) external;

	function frozenAccounts(address _target) external view returns (bool isFrozen);

	function setFrozenAccount(address _target, bool _isFrozen) external;

	function increaseAllowance(address _owner,  address _spender, uint256 _increase) external;

	function decreaseAllowance(address _owner,  address _spender, uint256 _decrease) external;
}

interface Ledger {
	function addTransaction(address _from, address _to, uint _tokens) external;
}

interface WhitelistData {
	function kycId(address _customer) external view returns (bytes32);
}


/**
 * @title ERC20Standard token
 * @dev Implementation of the basic standard token.
 * @notice https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Standard {
	
	using SafeMath for uint256;

	EternalDataStorage internal dataStorage;

	Ledger internal ledger;

	WhitelistData internal whitelist;

	/**
	 * @dev Triggered when tokens are transferred.
	 * @notice MUST trigger when tokens are transferred, including zero value transfers.
	 */
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	/**
	 * @dev Triggered whenever approve(address _spender, uint256 _value) is called.
	 * @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
	 */
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	modifier isWhitelisted(address _customer) {
		require(whitelist.kycId(_customer) != 0x0, 'Whitelisted customer required.');
		_;
	}

	/**
	 * @dev Constructor function that instantiates the EternalDataStorage, Ledger and Whitelist contracts.
	 * @param _dataStorage Address of the Data Storage Contract.
	 * @param _ledger Address of the Ledger Contract.
	 * @param _whitelist Address of the Whitelist Data Contract.
	 */
	constructor(address _dataStorage, address _ledger, address _whitelist) public {
		require(_dataStorage != address(0), 'Non-zero data storage address required.');
		require(_ledger != address(0), 'Non-zero ledger address required.');
		require(_whitelist != address(0), 'Non-zero whitelist address required.');

		dataStorage = EternalDataStorage(_dataStorage);
		ledger = Ledger(_ledger);
		whitelist = WhitelistData(_whitelist);
	}

	/**
	 * @dev Gets the total supply of tokens.
	 * @return totalSupplyAmount The total amount of tokens.
	 */
	function totalSupply() public view returns (uint256 totalSupplyAmount) {
		return dataStorage.totalSupply();
	}

	/**
	 * @dev Get the balance of the specified `_owner` address.
	 * @return balance The token balance of the given address.
	 */
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return dataStorage.balances(_owner);
	}

	/**
	 * @dev Transfer token to a specified address.
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 * @return success True if the transfer was successful, or throws.
	 */
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	/**
	 * @dev Transfer `_value` tokens to `_to` in behalf of `_from`.
	 * @param _from The address of the sender.
	 * @param _to The address of the recipient.
	 * @param _value The amount to send.
	 * @return success True if the transfer was successful, or throws.
	 */    
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		uint256 allowed = dataStorage.allowed(_from, msg.sender);
		require(allowed >= _value, 'From account has insufficient balance');

		allowed = allowed.sub(_value);
		dataStorage.setAllowance(_from, msg.sender, allowed);

		return _transfer(_from, _to, _value);
	}

	/**
	 * @dev Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount.
	 * approve will revert if allowance of _spender is 0. increaseApproval and decreaseApproval should
	 * be used instead to avoid exploit identified here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * @notice If this function is called again it overwrites the current allowance with `_value`.
	 * @param _spender The address authorized to spend.
	 * @param _value The max amount they can spend.
	 * @return success True if the operation was successful, or false.
	 */
	 
	function approve(address _spender, uint256 _value) public returns (bool success) {
		require(_value == 0 || dataStorage.allowed(msg.sender, _spender) == 0, 
			'Approve value is required to be zero or account has already been approved.');
		dataStorage.setAllowance(msg.sender, _spender, _value);
		
		emit Approval(msg.sender, _spender, _value);
		
		return true;
	}

	/**
	 * @dev Increase the amount of tokens that an owner allowed to a spender.
	 * This function must be called for increasing approval from a non-zero value
	 * as using approve will revert. It has been added as a fix to the exploit mentioned
	 * here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * @param _spender The address which will spend the funds.
	 * @param _addedValue The amount of tokens to increase the allowance by.
	 */
	function increaseApproval(address _spender, uint256 _addedValue) public {
		dataStorage.increaseAllowance(msg.sender, _spender, _addedValue);
		
		emit Approval(msg.sender, _spender, dataStorage.allowed(msg.sender, _spender));
	}

	/**
	 * @dev Decrease the amount of tokens that an owner allowed to a spender.
	 * This function must be called for decreasing approval from a non-zero value
	 * as using approve will revert. It has been added as a fix to the exploit mentioned
	 * here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * @param _spender The address which will spend the funds.
	 * @param _subtractedValue The amount of tokens to decrease the allowance by.
	 */
	function decreaseApproval(address _spender, uint256 _subtractedValue) public {		
		dataStorage.decreaseAllowance(msg.sender, _spender, _subtractedValue);
		
		emit Approval(msg.sender, _spender, dataStorage.allowed(msg.sender, _spender));
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner The address which owns the funds.
	* @param _spender The address which will spend the funds.
	* @return A uint256 specifying the amount of tokens still available for the spender.
	*/
	function allowance(address _owner, address _spender) public view returns (uint256) {
		return dataStorage.allowed(_owner, _spender);
	}

	/**
	 * @dev Internal transfer, can only be called by this contract.
	 * @param _from The address of the sender.
	 * @param _to The address of the recipient.
	 * @param _value The amount to send.
	 * @return success True if the transfer was successful, or throws.
	 */
	function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
		require(_to != address(0), 'Non-zero to-address required.');
		uint256 fromBalance = dataStorage.balances(_from);
		require(fromBalance >= _value, 'From-address has insufficient balance.');

		fromBalance = fromBalance.sub(_value);

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(_value);

		dataStorage.setBalance(_from, fromBalance);
		dataStorage.setBalance(_to, toBalance);

		ledger.addTransaction(_from, _to, _value);

		emit Transfer(_from, _to, _value);

		return true;
	}
}