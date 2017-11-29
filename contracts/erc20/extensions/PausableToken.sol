pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Pausable.sol';

contract PausableToken is ERC20Standard, Pausable {
    function PausableToken(address dataStorageAddress, address ledgerAddress) ERC20Standard(dataStorageAddress, ledgerAddress) public {}
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
    return super.transfer(_to, _value);
  }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
    return super.approve(_spender, _value);
  }
}