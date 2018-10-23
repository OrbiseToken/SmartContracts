pragma solidity 0.4.24;


contract ERC20 {
	function transfer(address _to, uint256 _value) public returns (bool success);
	function balanceOf(address _owner) public returns (uint256 balance);
}


contract AirDrop {

	address public owner;

	modifier onlyOwner {
		require(msg.sender == owner, 'Invoker must be msg.sender');
		_;
	}

	constructor() public {
		owner = msg.sender;
	}

    /**
     * @notice MultiTransfer function for airdrop
     * @param _token ERC20 token address that will get airdrop (this contract must have sufficient tokens to execute this function)
	 * @param _amount The amount of tokens to be transfered to each target
     * @param _targets The target addresses that will receive the free tokens
     */
	function airdrop(address _token, uint256 _amount, address[] _targets) public onlyOwner {
		require(_targets.length > 0, 'Target addresses must not be 0');
		require(_targets.length <= 64, 'Target array length is too big');
		require
        (
			_amount * _targets.length <= ERC20(_token).balanceOf(address(this)), 
			'Airdrop contract does not have enough tokens to execute the airdrop'
		);

		for (uint8 target = 0; target < _targets.length; target++) {
			ERC20(_token).transfer(_targets[target], _amount);
		}
	}
}