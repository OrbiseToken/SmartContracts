pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';

contract FreezableToken is ERC20Standard, Ownable {

    event FrozenFunds(address indexed target, uint256 amount);

    event UnfrozenFunds(address indexed target, uint256 amount);
    
    function FreezableToken(address dataStorageAddress, address ledgerAddress) ERC20Standard(dataStorageAddress, ledgerAddress) public {}

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

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        bool isFromFrozen;
        (isFromFrozen,) = dataStorage.getFrozenAccount(_from);
        require(!isFromFrozen);

        bool isToFrozen;
        (isToFrozen,) = dataStorage.getFrozenAccount(_from);
        require(!isToFrozen);
        
        return super._transfer(_from, _to, _value);
    }
}