pragma solidity ^0.4.18;

contract Ledger {
    
    int public backedTokens;
    int public unbackedTokens;
    address private owner;
    
    function Ledger() public {
        backedTokens = 0;
        unbackedTokens = 0;
        owner = msg.sender;
    }
    
    function receiveUnbackedTokens(int _tokenCount) public {
        unbackedTokens += _tokenCount;
    }
    
    function receiveBackedTokens(int _tokenCount) public {
        require(unbackedTokens - _tokenCount >= 0);
        unbackedTokens -= _tokenCount;
        backedTokens += _tokenCount;
    }

    function destroy() private {
        selfdestruct(owner);
    }
}