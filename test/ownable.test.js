const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_ownable', function ([owner, anotherAccount, otherAccount]) {

	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		const whitelist = await WhitelistData.new({ from: owner });
		const price = await web3.toWei('1', 'ether');
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, whitelist.address, { from: owner });
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	it('Ownable contract Should only allow owners to access onlyOwners functions', async function () {
		await testUtil.assertRevert(this.token.setOwner(otherAccount, true, { from: anotherAccount }));
	});

	describe('Ownable contract should allow multiple owners', function () {
		it('setOwner Should allow owners to add more owners', async function () {
			await this.token.setOwner(anotherAccount, true, { from: owner });
			const isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, true);
		});

		it('setOwner Should allow owners to remove existing owners', async function () {
			await this.token.setOwner(anotherAccount, true, { from: owner });
			let isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, true);
			await this.token.setOwner(anotherAccount, false, { from: owner });
			isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, false);
		});
	});
});