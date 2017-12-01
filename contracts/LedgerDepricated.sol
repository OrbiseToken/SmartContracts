pragma solidity ^0.4.18;

import './modifiers/Ownable.sol';
import './common/SafeMath.sol';

contract LedgerDepricated is Ownable {

    using SafeMath for uint256;
    
    uint private backedTokens;
    uint private unbackedTokens;
    
    function LedgerDepricated() public {
    }

    function getBackedTokens() public view returns (uint) {
        return backedTokens;
    }

    function getUnbackedTokens() public view returns (uint) {
        return unbackedTokens;
    }

    function setBackedTokens(uint value) public onlyOwners returns (bool) {
        backedTokens = value;
        return true;
    }

    function setUnbackedTokens(uint value) public onlyOwners returns (bool) {
        unbackedTokens = value;
        return true;
    }

    function receiveUnbackedTokens(uint _tokenCount) public onlyOwners returns (bool) {
        unbackedTokens = SafeMath.add(unbackedTokens, _tokenCount);
        return true;
    }
    
    function receiveBackedTokens(uint _tokenCount) public onlyOwners returns (bool) {
        unbackedTokens = SafeMath.sub(unbackedTokens, _tokenCount);
        backedTokens = SafeMath.add(backedTokens, _tokenCount);
        return true;
    }

    function destroy() public onlyOwners returns (bool) {
        selfdestruct(msg.sender);
        return true;
    }
}