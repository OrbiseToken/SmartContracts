pragma solidity 0.4.21;

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
	string public constant name = 'Orbis';

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
	* @param _dataStorageAddress Address of the Data Storage Contract.
	* @param _ledgerAddress Address of the Data Storage Contract.
	* @param _initialSellPrice Sets the initial sell price of the token.
	* @param _initialBuyPrice Sets the initial buy price of the token.
	* @param _walletAddress Sets the address of the wallet of the contract.
	*/
	function ERC20Extended(
		address _dataStorageAddress,
		address _ledgerAddress,
		uint256 _initialSellPrice,
		uint256 _initialBuyPrice,
		address _walletAddress
		) 
		FreezableToken(_dataStorageAddress, _ledgerAddress) 
		PausableToken(_dataStorageAddress, _ledgerAddress) 
		BurnableToken(_dataStorageAddress, _ledgerAddress) 
		MintableToken(_dataStorageAddress, _ledgerAddress) 
		public 
	{
		sellPrice = _initialSellPrice;
		buyPrice = _initialBuyPrice;
		wallet = _walletAddress;
	}

	/**
	* @dev Fallback function that allows the contract
	* to recieve Ether directly.
	*/
	function() payable public { }

	/**
	* @dev Function that sets both the sell and the buy price of the token.
	* @param _sellPrice The price at which the token will be sold.
	* @param _buyPrice The price at which the token will be bought.
	* @return success True on operation completion.
	*/
	function setPrices(uint256 _sellPrice, uint256 _buyPrice) public onlyOwners returns (bool success) {
		sellPrice = _sellPrice;
		buyPrice = _buyPrice;
		return true;
	}

	/**
	* @dev Function that sets the current wallet address.
	* @param _walletAddress The address of wallet to be set.
	* @return success True on operation completion, or throws.
	*/
	function setWallet(address _walletAddress) public onlyOwners returns (bool success) {
		require(_walletAddress != address(0));
		wallet = _walletAddress;
		return true;
	}

	/**
	* @dev Send Ether to buy tokens at the current token sell price.
	* @return success True on operation completion, or throws.
	*/
	function buy() payable whenNotPaused public returns (bool success) {
		uint256 amount = msg.value.mul(1 ether);

		amount = amount.div(sellPrice);
		
		assert(_transfer(this, msg.sender, amount));
		return true;
	}
	
	/**
	* @dev Sell `_amount` tokens at the current buy price.
	* @param _amount The amount to sell.
	* @return success True on operation completion, or throws.
	*/
	function sell(uint256 _amount) whenNotPaused public returns (bool success) {
		uint256 toBeTransferred = _amount.mul(buyPrice);

		toBeTransferred = toBeTransferred.div(1 ether);

		require(address(this).balance >= toBeTransferred);
		assert(_transfer(msg.sender, this, _amount));
		
		msg.sender.transfer(toBeTransferred);
		return true;
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
	* @return success True on operation completion, or throws.
	*/
	function withdraw(uint256 _amount) onlyOwners public returns (bool success) {
		require(address(this).balance >= _amount);
		wallet.transfer(_amount);
		return true;
	}

	/**
	* @dev Transfer, which is used when Orbis is bought with different currency than ETH.
	* @param _to The address of the recipient.
	* @param _value The amount of Orbis Tokens to transfer.
	* @return success True if the transfer was successful, or throws.
	*/
	function nonEtherPurchaseTransfer(address _to, uint256 _value) onlyOwners whenNotPaused public returns (bool success) {
		return _transfer(this, _to, _value);
	}
	
}