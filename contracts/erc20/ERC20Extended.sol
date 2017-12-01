pragma solidity ^0.4.18;

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
    string private constant NAME = "Example Name";

    string private constant SYMBOL = "EX";

    uint8 private constant DECIMALS = 18;

    uint256 private sellPrice;

    uint256 private buyPrice;

    address private seller;

    address private buyer;

    /**
    * @dev Constructor function that calculates the total supply of tokens, 
    * sets the initial sell and buy prices and
    * passes arguments to base constructors.
    * @param _dataStorageAddress Address of the Data Storage Contract.
    * @param _ledgerAddress Address of the Data Storage Contract.
    * @param _initialSupply Sets the initial amount of tokens.
    * @param _initialSellPrice Sets the initial sell price of the token.
    * @param _initialBuyPrice Sets the initial buy price of the token.
    */
    function ERC20Extended(address _dataStorageAddress, address _ledgerAddress, uint256 _initialSupply, uint256 _initialSellPrice, uint256 _initialBuyPrice) 
        FreezableToken(_dataStorageAddress, _ledgerAddress) 
        PausableToken(_dataStorageAddress, _ledgerAddress) 
        BurnableToken(_dataStorageAddress, _ledgerAddress) 
        MintableToken(_dataStorageAddress, _ledgerAddress) 
        public {
        uint256 calculatedTotalSupply = _initialSupply * 10 ** uint256(DECIMALS);
        require(dataStorage.setTotalSupply(calculatedTotalSupply));
        require(dataStorage.setBalance(msg.sender, calculatedTotalSupply));
        sellPrice = _initialSellPrice;
        buyPrice = _initialBuyPrice;
    }

    /**
    * @dev Function that returns the name of the token.
    * @return The name of the token.
    */
    function name() public pure returns (string) {
        return NAME;
    }

    /**
    * @dev Function that returns the symbol of the token.
    * @return The symbol of the token.
    */
    function symbol() public pure returns (string) {
        return SYMBOL;
    }

    /**
    * @dev Function that returns the number of decimals of the token.
    * @return The number of decimals of the token.
    */
    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    /**
    * @dev Function that gets the sell price of the token.
    * @return The sell price of the token.
    */
    function getSellPrice() public view returns (uint256) {
        return sellPrice;
    }

    /**
    * @dev Function that sets the sell price of the token.
    * @param _price The price which should be set.
    * @return success True on operation completion.
    */
    function setSellPrice(uint256 _price) public onlyOwners returns (bool success) {
        sellPrice = _price;
        return true;
    }

    /**
    * @dev Function that gets the buy price of the token.
    * @return The buy price of the token.
    */
    function getBuyPrice() public view returns (uint256) {
        return buyPrice;
    }

    /**
    * @dev Function that sets the buy price of the token.
    * @param _price The price which should be set.
    * @return success True on operation completion.
    */
    function setBuyPrice(uint256 _price) public onlyOwners returns (bool success) {
        buyPrice = _price;
        return true;
    }

    /**
    * @dev Function that gets the current token seller.
    * @return Address of the seller.
    */
    function getSeller() public view returns (address) {
        return seller;
    }

    /**
    * @dev Function that sets the current token seller.
    * @param _sellerAddress The address of the token seller.
    * @return success True on operation completion, or throws.
    */
    function setSeller(address _sellerAddress) public onlyOwners returns (bool success) {
        require(_sellerAddress != address(0));
        seller = _sellerAddress;
        return true;
    }

    /**
    * @dev Function that gets the current token buyer.
    * @return Address of the buyer.
    */
    function getBuyer() public view returns (address) {
        return buyer;
    }

    /**
    * @dev Function that sets the current token buyer.
    * @param _buyerAddress The address of the token buyer.
    * @return success True on operation completion, or throws.
    */
    function setBuyer(address _buyerAddress) public onlyOwners returns (bool success) {
        require(_buyerAddress != address(0));
        buyer = _buyerAddress;
        return true;
    }

    /**
    * @dev Send Ether to buy tokens at the current token buy price.
    */
    function buy() payable whenNotPaused public {
        uint256 amount = msg.value.div(buyPrice);
        _transfer(seller, msg.sender, amount);
    }
    
    /**
    * @dev Sell `_amount` tokens at the current sell price.
    * @param _amount The amount to sell.
    */
    function sell(uint256 _amount) whenNotPaused public {
        uint256 toBeTransferred = _amount.mul(sellPrice);
        require(buyer.balance >= toBeTransferred);
        require(_transfer(msg.sender, buyer, _amount));
        msg.sender.transfer(toBeTransferred);
    }
}
