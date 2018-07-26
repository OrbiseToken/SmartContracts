pragma solidity 0.4.24;

import '../modifiers/BotOperated.sol';

/**
 * @title WhitelistData
 * @dev The WhitelistData contract holds whitelisted addresses, and provides functionality for adding and removing addresses
 */
contract WhitelistData is BotOperated {
	
	event LogNewCustomer(address customer, bytes32 id);
	event LogCustomerUpdate(address customer, bytes32 id);
	event LogCustomerDeleted(address customer, bytes32 id);

	/**
	 * @dev Allows for checking if address is whitelisted and if so, provides the address id
	 * @param _customer The whitelisted address to check address id
	 * @return id
	 */
	mapping(address => bytes32) public kycId;
	
	/**
	 * @dev modifier to check for zero address
	 */
	modifier isCustomerSpecified(address _customer) {
		require(_customer != address(0), 'Non-zero customer address required when adding new customer.');
		_;
	}

	/**
	 * @dev modifier to check for zero address
	 */
	modifier isIdSpecified(bytes32 _id) {
		require(_id != 0x0, 'Non-zero customer id required when adding new customer.');
		_;
	}
	
	/**
	 * @dev Function to whitelist a single address
	 * @param _customer Address to be whitelisted
	 * @param _id Whitelisted address id
	 */
	function addSingleCustomer
	(
		address _customer,
		bytes32 _id
	) 
		public
		onlyBotsOrOwners
	{
		_addCustomer(_customer, _id);
	}
	
	/**
	 * @dev Function to whitelist many addresses
	 * @param _customers Address array to be whitelisted
	 * @param _ids Whitelisted addresses id array
	 */
	function addManyCustomers
	(
		address[] _customers,
		bytes32[] _ids
	)
		public
		onlyBotsOrOwners
	{
		require(_customers.length == _ids.length && _customers.length <= 128,
			'Less than or equal to 128 customers can be added at once and customer array length must be equal to id array length.');
		
		for (uint8 i = 0; i < _customers.length; i++) {
			_addCustomer(_customers[i], _ids[i]);
		}
	}

	/**
	 * @dev Function to delete a single address from the whitelist
	 * @param _customer Address to be whitelisted
	 */
	function deleteCustomer
	(
		address _customer
	) 
		public
		onlyBotsOrOwners
		isCustomerSpecified(_customer)
	{
		bytes32 id = kycId[_customer];

		emit LogCustomerDeleted(_customer, id);

		delete kycId[_customer];
	}
	
	/**
	 * @dev Internal function to whitelist a single address
	 * @param _customer Address to be whitelisted
	 * @param _id Whitelisted address id
	 */
	function _addCustomer
	(
		address _customer,
		bytes32 _id
	) 
		private 
		isCustomerSpecified(_customer)
		isIdSpecified(_id)
	{
		if (kycId[_customer] == 0x0) {
			emit LogNewCustomer(_customer, _id);
			kycId[_customer] = _id; 
		} else {
			uint8 currentLevel = uint8(kycId[_customer][31]);
			uint8 newLevel = uint8(_id[31]); 
			
			if (newLevel > currentLevel) {
				emit LogCustomerUpdate(_customer, _id);
				kycId[_customer] = _id;
			}
		}
	}
}