pragma solidity 0.4.24;

import "./Ownable.sol";


contract BotOperated is Ownable {
	mapping(address => bool) public bots;

	modifier onlyBotsOrOwners() {
		require(bots[msg.sender] || owners[msg.sender], "Bot or owner message sender required.");
		_;
	}

	modifier onlyBots() {
		require(bots[msg.sender], "Bot message sender required.");
		_;
	}

	constructor() public {
		bots[msg.sender] = true;
	}

	function setBot(address _bot, bool _isAllowed) public onlyOwners returns (bool success) {
		require(_bot != address(0), "Non-zero bot-address required.");
		bots[_bot] = _isAllowed;
		return true;
	}
}