pragma solidity ^0.4.18;

import './ERC20StandardData.sol';

contract ERC20ExtendedData is ERC20StandardData {
    mapping(address => bool) private frozenAccounts;


function getFrozenAccount(address target) public view returns (bool isFrozen, uint256 amount) {
    return (frozenAccounts[target], balances[target]);
}

function setFrozenAccount(address target, bool isFrozen) external fromContract returns (bool success, uint256 amount) {
    frozenAccounts[target] = isFrozen;
    return (true, balances[target]);
}
}