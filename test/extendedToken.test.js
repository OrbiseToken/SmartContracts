const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

const assertRevert = require('./utils/test.util.js').assertRevert;

contract('ERC20Extended', function ([owner, anotherAccount, wallet, bot]) {
	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		this.whitelist = await WhitelistData.new({ from: owner });
		const price = 1;
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, this.whitelist.address, { from: owner });
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	it('token Should have a fallback function', async function () {
		await this.token.sendTransaction({ from: anotherAccount, value: 1 });
		const balance = await this.token.getContractBalance();

		assert.equal(balance, 1);
	});

	describe('token Should have buy, sell and wallet setting functions', function () {
		it('setPrices Should allow owners to set the buy price for the token', async function () {
			const buyPrice = 2;
			const sellPrice = 5;

			await this.token.setPrices(sellPrice, buyPrice, { from: owner });

			const bp = await this.token.buyPrice();
			const sp = await this.token.sellPrice();

			assert.equal(buyPrice, bp);
			assert.equal(sellPrice, sp);
		});

		it('setWallet Should allow owners to set wallet address', async function () {
			await this.token.setWallet(wallet, { from: owner });

			const w = await this.token.wallet();
			assert.equal(wallet, w);
		});
	});

	describe('extended token has functions which allow accounts to exchange their tokens with ether', function () {
		beforeEach(async function () {
			await this.token.unpause({ from: owner });
			await this.token.mint(this.token.address, 1000e18, { from: owner });
			await this.whitelist.addSingleCustomer(anotherAccount, '0xe9ce785086f5c3b748f71d481085ecfed6e8b27dde50ff827a68cda21a68abdb');
			const { logs } = await this.token.buy({ from: anotherAccount, value: 200 });
			this.logs = logs;
		});

		it('buy Should revert when the invoker is not whitelisted', async function () {
			await this.whitelist.deleteCustomer(anotherAccount);
			const result = this.token.buy({ from: anotherAccount, value: 200 });
			await assertRevert(result);
		});

		it('buy Should allow accounts to give ether in exchange for tokens', async function () {
			const balance = await this.token.balanceOf(anotherAccount);
			assert.equal(balance, 200e18);
		});

		it('buy Should revert when not enough ether is sent to purchase tokens', async function () {
			const purchase = this.token.buy({ from: anotherAccount, value: 199});
			await assertRevert(purchase);
		})

		it('buy Should emit a Transfer event when called', async function () {
			assert.equal(this.logs[0].event, 'Transfer');
			assert.equal(this.logs[0].args._from, this.token.address);
			assert.equal(this.logs[0].args._to, anotherAccount);
			assert.equal(this.logs[0].args._value, 200e18);
		});

		it('sell Should allow accounts to give tokens in exchange for ether', async function () {
			await this.token.sell(200e18, { from: anotherAccount });
			const balance = await this.token.balanceOf(anotherAccount);
			const contractBalance = await this.token.balanceOf(this.token.address);

			assert.equal(balance, 0);
			assert.equal(contractBalance, 1000e18);
		});

		it('sell Should revert when too small an amount of tokens is sold', async function () {
			const newPrices = web3.toWei('0.5', 'ether');
			await this.token.setPrices(newPrices, newPrices, { from: owner });
			const sell = this.token.sell(1, {from: anotherAccount });
			await assertRevert(sell);
		})

		it('sell Should emit a Transfer event when called', async function () {
			const { logs } = await this.token.sell(100e18, { from: anotherAccount });

			assert.equal(logs[0].event, 'Transfer');
			assert.equal(logs[0].args._from, anotherAccount);
			assert.equal(logs[0].args._to, this.token.address);
			assert.equal(logs[0].args._value, 100e18);
		});
	});

	it('withdraw Should revert when the wallet is not set', async function () {
		await this.token.sendTransaction({ from: anotherAccount, value: 100 });
		const result = this.token.withdraw(100, { from: owner });
		await assertRevert(result);
	});

	it('withdraw Should allow owners to withdraw from token contract', async function () {
		await this.token.sendTransaction({ from: anotherAccount, value: 100 });
		await this.token.setWallet(wallet, { from: owner });
		await this.token.withdraw(100, { from: owner });
		const balanceAfterWithdraw = await this.token.getContractBalance();
		assert(balanceAfterWithdraw, 0);
	});

	it('nonEtherPurchaseTransfer Should allow bots to transfer tokens to specified account without ether', async function () {
		await this.token.unpause({ from: owner });
		await this.token.mint(bot, 100e18, { from: owner });
		await this.token.setBot(bot, true, { from: owner });
		this.whitelist.addSingleCustomer(anotherAccount, "0x004cfaa35c4f3c38af4a65376596f588a893bffca7bffbd507885d7079000c0d", { from: owner});
		await this.token.nonEtherPurchaseTransfer(anotherAccount, 100, { from: bot });
		const anotherBalance = await this.token.balanceOf(anotherAccount);

		assert.equal(anotherBalance, 100);
	});

	it('nonEtherPurchaseTransfer Should not allow non-bot to transfer tokens', async function () {
		await this.token.unpause({ from: owner });
		this.whitelist.addSingleCustomer(bot, "0x004cfaa35c4f3c38af4a65376596f588a893bffca7bffbd507885d7079000c0d", { from: owner});
		const transfer = this.token.nonEtherPurchaseTransfer(bot, 100, { from: anotherAccount});

		await assertRevert(transfer);
	});
});