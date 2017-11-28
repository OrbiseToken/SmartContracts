pragma solidity ^0.4.18;

import '../common/SafeMath.sol';

interface DataStorage {
function getBalance(address owner) public view returns (uint256);

function setBalance(address owner, uint256 value) external returns (bool success);

function getAllowance(address owner, address spender) public view returns (uint256);

function setAllowance(address owner, address spender, uint256 amount) external returns (bool success);

function getTotalSupply() public view returns (uint256);

function setTotalSupply(uint256 value) external returns (bool success);

function getFrozenAccount(address target) public view returns (bool isFrozen, uint256 amountFrozen);

function setFrozenAccount(address target, bool isFrozen) external returns (bool success, uint256 amountFrozen);
}

contract ERC20Standard {
    using SafeMath for uint;
}