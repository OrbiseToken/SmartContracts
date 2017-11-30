pragma solidity ^0.4.18;

import '../common/SafeMath.sol';

interface EternalDataStorage {
function getBalance(address owner) public view returns (uint256);

function setBalance(address owner, uint256 value) external returns (bool success);

function getAllowance(address owner, address spender) public view returns (uint256);

function setAllowance(address owner, address spender, uint256 amount) external returns (bool success);

function getTotalSupply() public view returns (uint256);

function setTotalSupply(uint256 value) external returns (bool success);

function getFrozenAccount(address target) public view returns (bool isFrozen, uint256 amountFrozen);

function setFrozenAccount(address target, bool isFrozen) external returns (bool success, uint256 amountFrozen);
}

interface Ledger {
    function receiveUnbackedTokens(uint256 value) public returns (bool success);
}

contract ERC20Standard {
    
    using SafeMath for uint256;

    EternalDataStorage internal dataStorage;

    Ledger internal ledger;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function ERC20Standard(address dataStorageAddress, address ledgerAddress) public {
        dataStorage = EternalDataStorage(dataStorageAddress);
        ledger = Ledger(ledgerAddress);
    }

    function totalSupply() public view returns (uint256 totalSupplyAmount) {
        return dataStorage.getTotalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return dataStorage.getBalance(_owner);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowed = dataStorage.getAllowance(_from, msg.sender);
        require(allowed >= _value);

        allowed = allowed.sub(_value);
        require(dataStorage.setAllowance(_from, msg.sender, allowed));

        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (dataStorage.setAllowance(msg.sender, _spender, _value)) {
            Approval(msg.sender, _spender, _value);
            return true;
        }

        return false;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return dataStorage.getAllowance(_owner, _spender);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != address(0));
        uint256 fromBalance = dataStorage.getBalance(_from);
        require(fromBalance >= _value);

        fromBalance = fromBalance.sub(_value);

        uint256 toBalance = dataStorage.getBalance(_to);
        toBalance = toBalance.add(_value);

        require(dataStorage.setBalance(_from, fromBalance));
        require(dataStorage.setBalance(_to, toBalance));

        Transfer(_from, _to, _value);

        return true;
    }
}