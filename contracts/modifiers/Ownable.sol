pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract holds owner addresses, and provides basic authorization control
 * functions.
 */
contract Ownable {
  mapping(address => bool) private owners; 

  /**
   * @dev The Ownable constructor adds the sender
   * account to the owners mapping.
   */
  function Ownable() public {
    owners[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwners() {
    require(owners[msg.sender] == true);
    _;
  }

  /**
   * @dev Allows the current owners to add new owner to the contract.
   * @param newOwner The address to grant owner rights.
   * @return true if the operation has passed or throws if failed.
   */
  function addOwner(address newOwner) public onlyOwners returns (bool success) {
    require(newOwner != address(0));
    owners[newOwner] = true;
    return true;
  }

    /**
   * @dev Allows the current owners to remove an existing owner from the contract.
   * @param owner The address to revoke owner rights.
   * @return true if the operation has passed or throws if failed.
   */
  function removeOwner(address owner) public onlyOwners returns (bool success) {
    require(owners[owner]);
    owners[owner] = false;
    return true;
  }

      /**
   * @dev Allows to check if the given address has owner rights.
   * @param owner The address to check for owner rights.
   * @return true if the adress is owner, false if it is not.
   */
  function isOwner(address owner) public view returns (bool) {
    return owners[owner];
  }
}