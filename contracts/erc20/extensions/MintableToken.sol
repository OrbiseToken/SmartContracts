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
		require(!mintingFinished, "Finished minting required.");
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	* @return success True if the operation was successful, or throws.
	*/
	function mint(address _to, uint256 _amount) onlyOwners canMint public returns (bool success) {
		uint256 calculatedAmount = _amount.mul(1 ether);

		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.add(calculatedAmount);
		require(dataStorage.setTotalSupply(totalSupply), "Unable to set total supply.");

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(calculatedAmount);
		require(dataStorage.setBalance(_to, toBalance), "Unable to set new account balance.");

		require(ledger.addTransaction(address(0), _to, calculatedAmount), "Unable to add mint transaction.");

		emit Transfer(address(0), _to, calculatedAmount);

		emit Mint(_to, calculatedAmount);
		
		return true;
	}

	/**
	* @dev Function to permanently stop minting new tokens.
	* @return success True if the operation was successful.
	*/
	function finishMinting() onlyOwners public returns (bool success) {
		mintingFinished = true;
		emit MintFinished();
		return true;
	}
}