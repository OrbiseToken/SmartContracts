pragma solidity 0.4.24;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';


/**
 * @title MintableToken
 * @dev ERC20Standard modified with mintable token creation.
 */
contract MintableToken is ERC20Standard, Ownable {

	/**
	* @dev Auto-generated function to check whether the minting has finished.
	* @return True if the minting has finished, or false.
	*/
	bool public mintingFinished = false;

	event Mint(address indexed _to, uint256 _amount);
	
	event MintFinished();

	modifier canMint() {
		require(!mintingFinished, 'Finished minting required.');
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	*/
	function mint(address _to, uint256 _amount) public onlyOwners canMint {
		uint256 calculatedAmount = _amount.mul(1 ether);

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.add(calculatedAmount);
		dataStorage.setTotalSupply(totalSupply);

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(calculatedAmount);
		dataStorage.setBalance(_to, toBalance);

		ledger.addTransaction(address(0), _to, calculatedAmount);

		emit Transfer(address(0), _to, calculatedAmount);

		emit Mint(_to, calculatedAmount);
	}

	/**
	* @dev Function to permanently stop minting new tokens.
	*/
	function finishMinting() public onlyOwners {
		mintingFinished = true;
		emit MintFinished();
	}
}