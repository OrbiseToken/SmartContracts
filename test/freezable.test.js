const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_freezable', function ([owner, frozen, anotherAccount]) {

	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		const whitelist = await WhitelistData.new({ from: owner });
		const price = await web3.toWei('1', 'ether');
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, whitelist.address, { from: owner });
		await whitelist.addSingleCustomer(frozen, '0xe9ce785086f5c3b748f71d481085ecfed6e8b27dde50ff827a68cda21a68abdb');
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	describe('as a basic freezable token', function () {
		it('accounts Should not be frozen by default', async function () {
			const isFrozen = await this.token.isAccountFrozen(frozen);
			assert.equal(isFrozen, false);
		});

		it('freezeAccount Should only be accessible by owners', async function () {
			const isFrozen = this.token.freezeAccount(frozen, true, { from: anotherAccount });
			await testUtil.assertRevert(isFrozen);
		});

		describe('when freezing account', function () {
			beforeEach(async function () {
				const { logs } = await this.token.freezeAccount(frozen, true, { from: owner });
				this.logs = logs;
			});

			it('freezeAccount Should freeze accounts', async function () {
				const isFrozen = await this.token.isAccountFrozen(frozen);
				assert.equal(isFrozen, true);
			});

			it('freezeAccount Should allow owner to unfreeze accounts', async function () {
				await this.token.freezeAccount(frozen, false, { from: owner });
				const isFrozen = await this.token.isAccountFrozen(frozen);
				assert.equal(isFrozen, false);
			});

			it('FrozenFunds event should be emitted', async function () {
				assert.equal(this.logs[0].event, 'FrozenFunds');
				assert.equal(this.logs[0].args._target, frozen);
				assert.equal(this.logs[0].args._isFrozen, true);
			});

			it('frozen accounts should not be able to transfer when frozen', async function () {
				await this.token.unpause({ from: owner });
				await this.token.mint(this.token.address, 200, { from: owner });
				const purchase = this.token.buy({ from: frozen, value: 200 });

				await testUtil.assertThrow(purchase);
			});
		});
	});
});