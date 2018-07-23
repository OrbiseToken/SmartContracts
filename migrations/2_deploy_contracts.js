const Ledger = artifacts.require("../contracts/ledger/Ledger.sol");
const ERC20ExtendedData = artifacts.require("../contracts/erc20/data/ERC20ExtendedData.sol");
const WhitelistData = artifacts.require("../contracts/whitelist/WhitelistData.sol");
const ERC20Extended = artifacts.require("../contracts/erc20/ERC20Extended.sol");

module.exports = function (deployer) {
	deployer.then(async function () {
		await deployer.deploy(Ledger);
		const ledgerInstance = await Ledger.deployed();

		await deployer.deploy(ERC20ExtendedData);
		const ERC20DataInstance = await ERC20ExtendedData.deployed();

		await deployer.deploy(WhitelistData);
		const whitelistInstance = await WhitelistData.deployed();

		await deployer.deploy(ERC20Extended, ERC20DataInstance.address, ledgerInstance.address, whitelistInstance.address);
	});
};