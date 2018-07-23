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
		await testUtil.assertRevert(this.token.addOwner(otherAccount, { from: anotherAccount }));
	});

	describe('Ownable contract should allow multiple owners', function () {
		it('addOwner Should allow owners to add more owners', async function () {
			await this.token.addOwner(anotherAccount, { from: owner });
			const isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, true);
		});

		it('removeOwner Should allow owners to remove existing owners', async function () {
			await this.token.addOwner(anotherAccount, { from: owner });
			await this.token.removeOwner(anotherAccount, { from: owner });
			const isOwner = await this.token.owners(anotherAccount);
			assert.equal(isOwner, false);
		});

		it('removeOwner Should return false when attempting to remove non owner', async function () {
			const removal = await this.token.removeOwner.call(anotherAccount, { from: owner });

			assert.equal(removal, false);
		});
	});
});