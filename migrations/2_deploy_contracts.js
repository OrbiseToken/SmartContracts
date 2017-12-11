var SafeMath = artifacts.require("../contracts/common/SafeMath.sol");
var LedgerData = artifacts.require("../contracts/ledger/data/LedgerData.sol");
var Ledger = artifacts.require("../contracts/ledger/Ledger.sol");
var ERC20ExtendedData = artifacts.require("../contracts/erc20/data/ERC20ExtendedData.sol");
var ERC20Extended = artifacts.require("../contracts/erc20/ERC20Extended.sol");

var ledgerDataInstance;
var ledgerInstance;
var ERC20DataInstance;

module.exports = (deployer) => {
    deployer.deploy(SafeMath); // one should link the library to the contract, in order to use it.
    deployer.link(SafeMath, LedgerData);
    deployer.link(SafeMath, ERC20Extended);
    deployer.deploy(LedgerData)
        .then(async () => {
            ledgerDataInstance = await LedgerData.deployed();
            await deployer.deploy(Ledger, ledgerDataInstance.address);
            ledgerInstance = await Ledger.deployed();
        });
    deployer.deploy(ERC20ExtendedData)
        .then(async () => {
            ERC20DataInstance = await ERC20ExtendedData.deployed();
            await deployer.deploy(ERC20Extended, ERC20DataInstance.address, ledgerInstance.address, 1, 1, "0x0");
        });
};