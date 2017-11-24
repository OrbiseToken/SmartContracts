var Ledger = artifacts.require("../contracts/Ledger.sol");
var EventsLog = artifacts.require("../contracts/EventsLog.sol");
var SafeMath = artifacts.require("../contracts/common/SafeMath.sol");
var Ownable = artifacts.require("../contracts/modifiers/Ownable.sol");
var Pausable = artifacts.require("../contracts/modifiers/Pausable.sol");

module.exports = function(deployer) {
    deployer.deploy(Ledger);
    deployer.deploy(EventsLog);
    deployer.deploy(SafeMath); // one should link the library to the contract, in order to use it.
    deployer.deploy(Ownable);
    deployer.deploy(Pausable);
};