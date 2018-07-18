const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const LedgerData = artifacts.require('../contracts/ledger/data/LedgerData.sol');

contract('ERC20Extended_ownable', function ([owner, anotherAccount, otherAccount]) {
  
	beforeEach(async function () {
		const randomAddressForWallet = 0x5aeda56215b167893e80b4fe645ba6d5bab767de;
		const tokenStorage = await ERC20ExtendedData.new({from: owner});
		const ledgerData = await LedgerData.new({from: owner});
		const ledger = await Ledger.new(ledgerData.address, {from: owner});
		const price = await web3.toWei('1', 'ether');
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, price, price, randomAddressForWallet, {from: owner});
		await tokenStorage.setContractAddress(this.token.address, {from: owner});
		await ledger.setContractAddress(this.token.address, {from: owner});
		await ledgerData.setContractAddress(ledger.address, {from: owner});
	});

	it('Ownable contract Should only allow owners to access onlyOwners functions', async function () {
		await testUtil.assertRevert(this.token.addOwner(otherAccount, {from: anotherAccount}));
	});

	describe('Ownable contract should allow multiple owners', function () {
		it('addOwner Should allow owners to add more owners', async function () {
			await this.token.addOwner(anotherAccount, {from: owner});
			const isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, true);
		});
		
		it('removeOwner Should allow owners to remove existing owners', async function () {
			await this.token.addOwner(anotherAccount, {from: owner});
			await this.token.removeOwner(anotherAccount, {from: owner});
			const isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, false);
		});

		it('removeOwner Should return false when attempting to remove non owner', async function () {
			const removal = await this.token.removeOwner.call(anotherAccount, {from: owner});
			
			assert.equal(removal, false);
		});
	});
});