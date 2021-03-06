pragma solidity 0.4.24;

import './Ownable.sol';


/**
 * @title FromContract
 * @dev Base contract which allows calling members only from a specific external contract.
 */
contract FromContract is Ownable {
	address public contractAddress;

	/**
	* @dev modifier that throws if the call is not from the specified contract.
	*/
	modifier fromContract() {
		require(msg.sender == contractAddress, 'Function only callable from correct contract.');
		_;
	}

	/**
	* @dev allows the owner of the contract to set the contract address.
	* @param _newContractAddress The address to transfer current permission to.
	* @return True, if the operation has passed, or throws if failed.
	*/
	function setContractAddress(address _newContractAddress) public onlyOwners {
		require(_newContractAddress != address(0), 'Non-zero contract address required when setting allowed external contract address.');
		contractAddress = _newContractAddress;
	}
}