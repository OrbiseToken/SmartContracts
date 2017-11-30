pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';

contract BurnableToken is ERC20Standard, Ownable {

    event Burn(address indexed burner, uint256 value);
    
    function BurnableToken(address dataStorageAddress, address ledgerAddress) ERC20Standard(dataStorageAddress, ledgerAddress) public {}

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
}