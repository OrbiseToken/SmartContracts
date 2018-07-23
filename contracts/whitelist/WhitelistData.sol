pragma solidity 0.4.24;

import '../modifiers/Ownable.sol';


contract WhitelistData is Ownable {
    
	event LogNewCustomer(address customer, bytes32 id);
    event LogCustomerUpdate(address customer, bytes32 id);
	event LogCustomerDeleted(address customer, bytes32 id);

    bytes32 public constant BYTES32_DEFAULT_VALUE = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    
    mapping(address => bytes32) public kycId;
    
    modifier isCustomerSpecified(address _customer) {
        require(_customer != address(0));
        _;
    }
    
    modifier isIdSpecified(bytes32 _id) {
        require(_id != 0x0);
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
        require(_customers.length == _ids.length && _customers.length <= 128);
        
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