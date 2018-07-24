pragma solidity 0.4.24;

import '../modifiers/Ownable.sol';



/**
 * @title Destroyable
 * @dev Base contract that can be destroyed by the owners. All funds in contract will be sent back.
 */
contract Destroyable is Ownable {

	constructor() public payable { }

	/**
	* @dev Transfers The current balance to the message sender and terminates the contract.
	*/
	function destroy() onlyOwners public {
		selfdestruct(msg.sender);
	}

	/**
	* @dev Transfers The current balance to the specified _recipient and terminates the contract.
	* @param _recipient The address to send the current balance to.
	*/
	function destroyAndSend(address _recipient) onlyOwners public {
		require(_recipient != address(0), "Non-zero recepient address required.");
		selfdestruct(_recipient);
	}
}