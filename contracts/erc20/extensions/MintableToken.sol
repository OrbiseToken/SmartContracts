pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';

contract MintableToken is ERC20Standard, Ownable {

    bool private mintingFinished = false;

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    function MintableToken(address dataStorageAddress, address ledgerAddress) ERC20Standard(dataStorageAddress, ledgerAddress) public {}
    
    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwners canMint public returns (bool success) {
        uint256 totalSupply = dataStorage.getTotalSupply();
        totalSupply = totalSupply.add(_amount);
        require(dataStorage.setTotalSupply(totalSupply));

        uint256 toBalance = dataStorage.getBalance(_to);
        toBalance = toBalance.add(_amount);
        require(dataStorage.setBalance(_to, toBalance));

        Transfer(address(0), _to, _amount);

        return true;
    }

    function finishMinting() onlyOwners public returns (bool success) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function isMintingFinished() public view returns (bool) {
        return mintingFinished;
    }
}