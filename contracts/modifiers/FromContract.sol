pragma solidity ^0.4.18;

import './Ownable.sol';

/**
 * @title FromContract
 * @dev Base contract which allows calling members only from a specific external contract.
 */
 contract FromContract is Ownable {

  address public contractAddress;

  /**
   * @dev modifier that throws if the call is not from the specified contract.
   */
  modifier fromContract() {
    require(msg.sender == contractAddress);
    _;
  }

  /**
   * @dev allows the owner of the contract to set the contract address
   * @param newContractAddress The address to transfer current permission to.
   * @return true if the operation has passed or throws if failed
   */
  function setContractAddress(address newContractAddress) public onlyOwner returns (bool success) {
      require(newContractAddress != address(0));
      contractAddress = newContractAddress;
      return true;
  }
}