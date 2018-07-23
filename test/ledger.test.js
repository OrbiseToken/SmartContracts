const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_ledger', function ([owner]) {

	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		this.ledger = await Ledger.new({ from: owner });
		const price = await web3.toWei('1', 'ether');
		const whitelist = await WhitelistData.new({ from: owner });
		this.token = await ERC20Extended.new(tokenStorage.address, this.ledger.address, whitelist.address, { from: owner });
		await whitelist.addSingleCustomer(owner, '0xe9ce785086f5c3b748f71d481085ecfed6e8b27dde50ff827a68cda21a68abdb');
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await this.ledger.setContractAddress(this.token.address, { from: owner });
	});

	describe('ledger should allow past transactions to be accessed by index', function () {
		beforeEach(async function () {
			await this.token.unpause({ from: owner });
			await this.token.mint(this.token.address, 1, { from: owner });
			const { logs } = await this.token.buy({ from: owner, value: 100 });
			this.logs = logs;
		})

		it('users can get number of all past transactions', async function () {
			const transactionCount = await this.ledger.getTransactionsCount();
			assert.equal(transactionCount, 2);
		});

		it('users can get specific transaction by its index', async function () {
			const transferTransaction = await this.ledger.transactions(1);
			assert.equal(this.logs[0].event, 'Transfer');
			assert.equal(this.logs[0].args._from, transferTransaction[0]);
			assert.equal(this.logs[0].args._to, transferTransaction[1]);
			assert.equal(this.logs[0].args._value.valueOf(), transferTransaction[2].valueOf());
		});
	});
});