pragma solidity ^0.4.18;

import "../modifiers/Ownable.sol";

contract Destroyable is Ownable {

  function Destroyable() public payable { }

  function destroy() onlyOwners public {
    selfdestruct(msg.sender);
  }

  function destroyAndSend(address _recipient) onlyOwners public {
    selfdestruct(_recipient);
  }
}