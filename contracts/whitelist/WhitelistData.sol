pragma solidity 0.4.24;

import '../modifiers/Ownable.sol';


contract WhitelistData is Ownable {
    
	event LogNewCustomer(address customer, bytes32 id);
    event LogCustomerUpdate(address customer, bytes32 id);
	event LogCustomerDeleted(address customer, bytes32 id);

    mapping(address => bytes32) public kycId;
    
    modifier isCustomerSpecified(address _customer) {
        require(_customer != address(0), "Non-zero customer address required when adding new customer.");
        _;
    }
    
    modifier isIdSpecified(bytes32 _id) {
        require(_id != 0x0, "Non-zero customer id required when adding new customer.");
        _;
    }
    
    function addSingleCustomer
    (
        address _customer,
        bytes32 _id
    ) 
        public
        onlyOwners
    {
        _addCustomer(_customer, _id);
    }
    
    function addManyCustomers
    (
        address[] _customers,
        bytes32[] _ids
    )
        public
        onlyOwners
    {
        require(_customers.length == _ids.length && _customers.length <= 128, "Less than or equal to 128 customers can be added at once and customer array length must be equal to id array length.");
        
        for (uint8 i = 0; i < _customers.length; i++) {
            _addCustomer(_customers[i], _ids[i]);
        }
    }

	function deleteCustomer
	(
		address _customer
	) 
		public
		onlyOwners
        isCustomerSpecified(_customer)
	{
		bytes32 id = kycId[_customer];

		emit LogCustomerDeleted(_customer, id);

		delete kycId[_customer];
	}
    
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