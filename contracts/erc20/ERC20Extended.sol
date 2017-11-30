pragma solidity ^0.4.18;

import './ERC20Standard.sol';
import '../modifiers/Pausable.sol';
import '../common/Destroyable.sol';

contract ERC20Extended is ERC20Standard, Pausable, Destroyable {
    string private constant NAME = "Example Name";

    string private constant SYMBOL = "EX";

    uint8 private constant DECIMALS = 18;

    uint256 private sellPrice;

    uint256 private buyPrice;

    address private seller;

    address private buyer;

    function ERC20Extended(address dataStorageAddress, address ledgerAddress, uint256 initialSupply) ERC20Standard(dataStorageAddress, ledgerAddress) public {
        uint256 calculatedTotalSupply = initialSupply * 10 ** uint256(DECIMALS);
        require(dataStorage.setTotalSupply(calculatedTotalSupply));
        require(dataStorage.setBalance(msg.sender, calculatedTotalSupply));
    }

    function name() public pure returns (string _name) {
        return NAME;
    }

    function symbol() public pure returns (string _symbol) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8 _decimals) {
        return DECIMALS;
    }

    function getSellPrice() public view returns (uint256) {
        return sellPrice;
    }

    function setSellPrice(uint256 price) public onlyOwners returns (bool success) {
        sellPrice = price;
        return true;
    }

    function getBuyPrice() public view returns (uint256) {
        return buyPrice;
    }

    function setBuyPrice(uint256 price) public onlyOwners returns (bool success) {
        buyPrice = price;
        return true;
    }

    function getSeller() public view returns (address) {
        return seller;
    }

    function setSeller(address sellerAddress) public onlyOwners returns (bool success) {
        require(sellerAddress != address(0));
        seller = sellerAddress;
        return true;
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }

    function setBuyer(address buyerAddress) public onlyOwners returns (bool success) {
        require(buyerAddress != address(0));
        buyer = buyerAddress;
        return true;
    }

    function buy() payable whenNotPaused public {
        uint256 amount = msg.value.div(buyPrice);
        _transfer(seller, msg.sender, amount);
    }
    
    function sell(uint256 amount) whenNotPaused public {
        uint256 toBeTransferred = amount.mul(sellPrice);
        require(buyer.balance >= toBeTransferred);
        require(_transfer(msg.sender, buyer, amount));
        msg.sender.transfer(toBeTransferred);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
        return super.approve(_spender, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        bool isFromFrozen;
        (isFromFrozen,) = dataStorage.getFrozenAccount(_from);
        require(!isFromFrozen);

        bool isToFrozen;
        (isToFrozen,) = dataStorage.getFrozenAccount(_from);
        require(!isToFrozen);
        
        return super._transfer(_from, _to, _value);
    }

    function freezeAccount(address target) public onlyOwners returns (bool success, uint256 amount) {
        require(target != address(0));
        (success, amount) = dataStorage.setFrozenAccount(target, true);
        require(success);
        FrozenFunds(target, amount);
    }

    function unfreezeAccount(address target) public onlyOwners returns (bool success, uint256 amount) {
        require(target != address(0));
        (success, amount) = dataStorage.setFrozenAccount(target, false);
        require(success);
        UnfrozenFunds(target, amount);
    }

    function isAccountFrozen(address target) public view returns (bool isFrozen, uint256 amount) {
        return dataStorage.getFrozenAccount(target);
    }

    function burn(uint256 _value) public returns (bool success) {
        uint256 senderBalance = dataStorage.getBalance(msg.sender);
        require(senderBalance >= _value);
        senderBalance = senderBalance.sub(_value);
        require(dataStorage.setBalance(msg.sender, senderBalance));

        uint256 totalSupply = dataStorage.getTotalSupply();
        totalSupply = totalSupply.sub(_value);
        require(dataStorage.setTotalSupply(totalSupply));

        Burn(msg.sender, _value);

        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        uint256 fromBalance = dataStorage.getBalance(_from);
        require(fromBalance >= _value);

        uint256 allowed = dataStorage.getAllowance(_from, msg.sender);
        require(allowed >= _value);

        fromBalance = fromBalance.sub(_value);
        require(dataStorage.setBalance(_from, fromBalance));

        allowed = allowed.sub(_value);
        require(dataStorage.setAllowance(_from, msg.sender, allowed));

        uint256 totalSupply = dataStorage.getTotalSupply();
        totalSupply = totalSupply.sub(_value);
        require(dataStorage.setTotalSupply(totalSupply));

        Burn(_from, _value);

        return true;
    }

    event FrozenFunds(address indexed target, uint256 amount);

    event UnfrozenFunds(address indexed target, uint256 amount);

    event Burn(address indexed burner, uint256 value);
}
