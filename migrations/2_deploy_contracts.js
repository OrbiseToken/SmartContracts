var Ledger = artifacts.require("../contracts/Ledger.sol");
var EventsLog = artifacts.require("../contracts/EventsLog.sol");
var SafeMath = artifacts.require("../contracts/common/SafeMath.sol");
var Ownable = artifacts.require("../contracts/modifiers/Ownable.sol");

module.exports = function(deployer) {
    deployer.deploy(Ledger);
    deployer.deploy(EventsLog);
    deployer.deploy(SafeMath);
    deployer.deploy(Ownable);
};