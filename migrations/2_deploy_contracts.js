var Ledger = artifacts.require("../contracts/Ledger.sol");
var EventsLog = artifacts.require("../contracts/EventsLog.sol");

module.exports = function(deployer) {
    deployer.deploy(Ledger);
    deployer.deploy(EventsLog);
};