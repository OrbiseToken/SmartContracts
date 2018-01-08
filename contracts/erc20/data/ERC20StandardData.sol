pragma solidity ^0.4.18;

import "../../modifiers/FromContract.sol";

/**
 * @title ERC20StandardData
 * @dev Contract that manages the data for ERC20Standard contract and allows modifying data only from it.
 */
contract ERC20StandardData is FromContract {

    mapping(address => uint256) public balances;

    mapping(address => mapping (address => uint256)) public allowed;

    uint256 public totalSupply;

    function setBalance(address _owner, uint256 _value) external fromContract returns (bool success) {
        balances[_owner] = _value;
        return true;
    }

    function setAllowance(address _owner, address _spender, uint256 _amount) external fromContract returns (bool success) {
        allowed[_owner][_spender] = _amount;
        return true;
    }

    function setTotalSupply(uint256 _value) external fromContract returns (bool success) {
        totalSupply = _value;
        return true;
    }
}