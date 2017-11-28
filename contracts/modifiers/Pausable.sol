pragma solidity ^0.4.18;

import './Ownable.sol';

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   * @return true if the operation has passed
   */
  function pause() public onlyOwner returns (bool success) {
    paused = true;
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   * @return true if the operation has passed
   */
  function unpause() public onlyOwner returns (bool success) {
    paused = false;
    return true;
  }
}