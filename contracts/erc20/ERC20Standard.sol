pragma solidity ^0.4.18;

import '../modifiers/Ownable.sol';

interface DataStorage {
function getBalance(address owner) public view returns (uint256);

function setBalance(address owner, uint256 value) external returns (bool success);

function getAllowance(address owner, address spender) public view returns (uint256);

function setAllowance(address owner, address spender, uint256 amount) external returns (bool success);

function getTotalSupply() public view returns (uint256);

function setTotalSupply(uint256 value) external returns (bool success);
}

contract ERC20Standard {
}