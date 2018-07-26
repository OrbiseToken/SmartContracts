pragma solidity 0.4.24;

import './extensions/FreezableToken.sol';
import './extensions/PausableToken.sol';
import './extensions/BurnableToken.sol';
import './extensions/MintableToken.sol';
import '../common/Destroyable.sol';


/**
 * @title ERC20Extended
 * @dev Standard ERC20 token with extended functionalities.
 */
contract ERC20Extended is FreezableToken, PausableToken, BurnableToken, MintableToken, Destroyable {
	/**
	* @dev Auto-generated function that returns the name of the token.
	* @return The name of the token.
	*/
	string public constant name = 'Orbise';

	/**
	* @dev Auto-generated function that returns the symbol of the token.
	* @return The symbol of the token.
	*/
	string public constant symbol = 'ORB';

	/**
	* @dev Auto-generated function that returns the number of decimals of the token.
	* @return The number of decimals of the token.
	*/
	uint8 public constant decimals = 18;

	/**
	* @dev Auto-generated function that gets the price at which the token is sold.
	* @return The sell price of the token.
	*/
	uint256 public sellPrice;

	/**
	* @dev Auto-generated function that gets the price at which the token is bought.
	* @return The buy price of the token.
	*/
	uint256 public buyPrice;

	/**
	* @dev Auto-generated function that gets the address of the wallet of the contract.
	* @return The address of the wallet.
	*/
	address public wallet;

	/**
	* @dev Constructor function that calculates the total supply of tokens, 
	* sets the initial sell and buy prices and
	* passes arguments to base constructors.
	* @param _dataStorage Address of the Data Storage Contract.
	* @param _ledger Address of the Data Storage Contract.
	* @param _whitelist Address of the Whitelist Data Contract.
	*/
	constructor
	(
		address _dataStorage,
		address _ledger,
		address _whitelist
	)
		ERC20Standard(_dataStorage, _ledger, _whitelist)
		public 
	{
	}

	/**
	* @dev Fallback function that allows the contract
	* to receive Ether directly.
	*/
	function() public payable { }

	/**
	* @dev Function that sets both the sell and the buy price of the token.
	* @param _sellPrice The price at which the token will be sold.
	* @param _buyPrice The price at which the token will be bought.
	*/
	function setPrices(uint256 _sellPrice, uint256 _buyPrice) public onlyBotsOrOwners {
		sellPrice = _sellPrice;
		buyPrice = _buyPrice;
	}

	/**
	* @dev Function that sets the current wallet address.
	* @param _walletAddress The address of wallet to be set.
	*/
	function setWallet(address _walletAddress) public onlyOwners {
		require(_walletAddress != address(0), 'Non-zero wallet address required.');
		wallet = _walletAddress;
	}

	/**
	* @dev Send Ether to buy tokens at the current token sell price.
	*/
	function buy() public payable whenNotPaused isWhitelisted(msg.sender) {
		uint256 amount = msg.value.mul(1 ether);

		amount = amount.div(sellPrice);
		
		_transfer(this, msg.sender, amount);
	}
	
	/**
	* @dev Sell `_amount` tokens at the current buy price.
	* @param _amount The amount to sell.
	*/
	function sell(uint256 _amount) public whenNotPaused {
		uint256 toBeTransferred = _amount.mul(buyPrice);

		toBeTransferred = toBeTransferred.div(1 ether);

		require(address(this).balance >= toBeTransferred, 'Contract has insufficient balance.');
		_transfer(msg.sender, this, _amount);
		
		msg.sender.transfer(toBeTransferred);
	}

	/**
	* @dev Get the contract balance in WEI.
	*/
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	/**
	* @dev Withdraw `_amount` ETH to the wallet address.
	* @param _amount The amount to withdraw.
	*/
	function withdraw(uint256 _amount) public onlyOwners {
		require(address(this).balance >= _amount, 'Unable to withdraw specified amount.');
		require(wallet != address(0), 'Non-zero wallet address required.');
		wallet.transfer(_amount);
	}

	/**
	* @dev Transfer, which is used when Orbise is bought with different currency than ETH.
	* @param _to The address of the recipient.
	* @param _value The amount of Orbise Tokens to transfer.
	* @return success True if operation is executed successfully.
	*/
	function nonEtherPurchaseTransfer(address _to, uint256 _value) public onlyBots whenNotPaused returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}
}