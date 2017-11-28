pragma solidity ^0.4.18;

import '../modifiers/FromContract.sol';

contract ERC20StandardData is FromContract {

    mapping(address => uint256) private balances;

    mapping(address => mapping (address => uint256)) private allowed;

    uint256 private totalSupply;

    function getBalance(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function setBalance(address owner, uint256 value) external fromContract returns (bool success) {
        balances[owner] = value;
        return true;
    }

    function getAllowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function setAllowance(address owner, address spender, uint256 amount) external fromContract returns (bool success) {
        allowed[owner][spender] = amount;
        return true;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function setTotalSupply(uint256 value) external onlyOwners fromContract returns (bool success) {
        totalSupply = value;
        return true;
    }
}