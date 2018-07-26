pragma solidity 0.4.24;

import './BotOperated.sol';


/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
*/
contract Pausable is BotOperated {
	event Pause();
	event Unpause();

	bool public paused = true;

	/**
	* @dev Modifier to allow actions only when the contract IS NOT paused.
	*/
	modifier whenNotPaused() {
		require(!paused, 'Unpaused contract required.');
		_;
	}

	/**
	* @dev Called by the owner to pause, triggers stopped state.
	* @return True if the operation has passed.
	*/
	function pause() public onlyBotsOrOwners {
		paused = true;
		emit Pause();
	}

	/**
	* @dev Called by the owner to unpause, returns to normal state.
	* @return True if the operation has passed.
	*/
	function unpause() public onlyBotsOrOwners {
		paused = false;
		emit Unpause();
	}
}