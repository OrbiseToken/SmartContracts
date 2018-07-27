pragma solidity 0.4.24;

import './Ownable.sol';



/**
 * @title BotOperated
 * @dev The BotOperated contract holds bot addresses, and provides basic authorization control
 * functions.
 */
contract BotOperated is Ownable {
	/**
	* @dev Allows to check if the given address has bot rights.
	* @param _bot The address to check for bot rights.
	* @return True if the address is bot, false if it is not.
	*/
	mapping(address => bool) public bots;

	/**
	 * @dev Throws if called by any account other than bot or owner.
	 */
	modifier onlyBotsOrOwners() {
		require(bots[msg.sender] || owners[msg.sender], 'Bot or owner message sender required.');
		_;
	}

	/**
	* @dev Throws if called by any account other than the bot.
	*/
	modifier onlyBots() {
		require(bots[msg.sender], 'Bot message sender required.');
		_;
	}

	/**
	* @dev The BotOperated constructor adds the sender
	* account to the bots mapping.
	*/
	constructor() public {
		bots[msg.sender] = true;
	}

	/**
	* @dev Allows the current owners to grant or revoke 
	* bot-level access rights to the contract.
	* @param _bot The address to grant or revoke bot rights.
	* @param _isAllowed Boolean granting or revoking bot rights.
	* @return True if the operation has passed or throws if failed.
	*/
	function setBot(address _bot, bool _isAllowed) public onlyOwners {
		require(_bot != address(0), 'Non-zero bot-address required.');
		bots[_bot] = _isAllowed;
	}
}