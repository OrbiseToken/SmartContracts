const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_bot', function ([owner, bot]) {

	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		const whitelist = await WhitelistData.new({ from: owner });
		const price = 1;
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, whitelist.address, { from: owner });
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	describe('botOperated contract should allow multiple bots', function () {
		it('setBot Should allow owners to add more bots', async function () {
			await this.token.setBot(bot, true, { from: owner });
			const isBot = await this.token.bots(bot);
			assert.equal(isBot, true);
		});

		it('setBot Should allow owners to remove existing bots', async function () {
			await this.token.setBot(bot, true, { from: owner });
			let isBot = await this.token.bots(bot);
			assert.equal(isBot, true);
			await this.token.setBot(bot, false, { from: owner });
			isBot = await this.token.bots(bot);
			assert.equal(isBot, false);
		});
	});
});