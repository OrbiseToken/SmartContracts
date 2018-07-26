pragma solidity 0.4.24;



/**
 * @title Ownable
 * @dev The Ownable contract holds owner addresses, and provides basic authorization control
 * functions.
 */
contract Ownable {
	/**
	* @dev Allows to check if the given address has owner rights.
	* @param _owner The address to check for owner rights.
	* @return True if the address is owner, false if it is not.
	*/
	mapping(address => bool) public owners;
	
	/**
	* @dev The Ownable constructor adds the sender
	* account to the owners mapping.
	*/
	constructor() public {
		owners[msg.sender] = true;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwners() {
		require(owners[msg.sender], 'Owner message sender required.');
		_;
	}

	/**
	* @dev Allows the current owners to grant or revoke 
	* owner-level access rights to the contract.
	* @param _owner The address to grant or revoke owner rights.
	* @param _isAllowed Boolean granting or revoking owner rights.
	* @return True if the operation has passed or throws if failed.
	*/
	function setOwner(address _owner, bool _isAllowed) public onlyOwners returns (bool success) {
		require(_owner != address(0), 'Non-zero owner-address required.');
		owners[_owner] = _isAllowed;
		return true;
	}
}