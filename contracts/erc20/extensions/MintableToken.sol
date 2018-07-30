pragma solidity 0.4.24;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';


/**
 * @title MintableToken
 * @dev ERC20Standard modified with mintable token creation.
 */
contract MintableToken is ERC20Standard, Ownable {

	/**
	 * @dev Hardcap - maximum allowed amount of tokens to be minted
	 */
	uint104 public constant MINTING_HARDCAP = 1e30;

	/**
	* @dev Auto-generated function to check whether the minting has finished.
	* @return True if the minting has finished, or false.
	*/
	bool public mintingFinished = false;

	event Mint(address indexed _to, uint256 _amount);
	
	event MintFinished();

	modifier canMint() {
		require(!mintingFinished, 'Uninished minting required.');
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	*/
	function mint(address _to, uint256 _amount) public onlyOwners canMint() {
		uint256 totalSupply = dataStorage.totalSupply();
		totalSupply = totalSupply.add(_amount);
		
		require(totalSupply <= MINTING_HARDCAP, 'Total supply of token in circulation must be below hardcap.');
		
		dataStorage.setTotalSupply(totalSupply);

		uint256 toBalance = dataStorage.balances(_to);
		toBalance = toBalance.add(_amount);
		dataStorage.setBalance(_to, toBalance);

		ledger.addTransaction(address(0), _to, _amount);

		emit Transfer(address(0), _to, _amount);

		emit Mint(_to, _amount);
	}

	/**
	* @dev Function to permanently stop minting new tokens.
	*/
	function finishMinting() public onlyOwners {
		mintingFinished = true;
		emit MintFinished();
	}
}