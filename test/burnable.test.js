const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

const BigNumber = web3.BigNumber;
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

require('chai')
	.use(require('chai-as-promised'))
	.use(require('chai-bignumber')(BigNumber))
	.should();

contract('ERC20Extended_burnable', function ([owner, burner]) {

	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		const whitelist = await WhitelistData.new({ from: owner });
		const price = 1;
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, whitelist.address, { from: owner });
		await whitelist.addSingleCustomer(owner, '0xe9ce785086f5c3b748f71d481085ecfed6e8b27dde50ff827a68cda21a68abdb');
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	describe('as a basic burnable token', function () {
		const from = owner;

		describe('when the given amount is not greater than balance of the sender', function () {
			const amount = 200;

			beforeEach(async function () {
				await this.token.unpause({ from });
				await this.token.mint(this.token.address, 200e18, { from });
				await this.token.buy({ from: owner, value: amount });
				const initialSupply = await this.token.totalSupply();
				const { logs } = await this.token.burn(200e18, { from });
				this.logs = logs;
				this.initialSupply = initialSupply;
			});

			it('burns the requested amount', async function () {
				const balance = await this.token.balanceOf(from);
				balance.should.be.bignumber.equal(0);
			});

			it('totalSupply should be less after burning', async function () {
				const supply = await this.token.totalSupply();
				assert.deepEqual(supply.add(200e18), this.initialSupply);
			});

			it('emits a burn event', async function () {
				const event = await testUtil.inLogs(this.logs, 'Burn');
				event.args._burner.should.eq(owner);
				event.args._value.should.be.bignumber.equal(200e18);
			});

			it('emits a transfer event', async function () {
				const event = await testUtil.inLogs(this.logs, 'Transfer');

				event.args._from.should.eq(owner);
				event.args._to.should.eq(ZERO_ADDRESS);
				event.args._value.should.be.bignumber.equal(200e18);
			});
		});

		describe('when the given amount is greater than the balance of the sender', function () {
			const amount = 200;
			beforeEach(async function () {
				await this.token.unpause({ from });
				await this.token.mint(this.token.address, 200e18, { from });
				await this.token.buy({ from: owner, value: amount });
			});
			const greaterAmount = 201e18;

			it('reverts', async function () {
				await testUtil.assertRevert(this.token.burn(greaterAmount, { from }));
			});
		});
	});

	describe('burnFrom', function () {
		describe('on success', function () {
			const amount = 100;

			beforeEach(async function () {
				await this.token.unpause({ from: owner });
				await this.token.mint(this.token.address, 500e18, { from: owner });
				await this.token.buy({ from: owner, value: 500 });
				await this.token.approve(burner, 300e18, { from: owner });
				const initialSupply = this.token.totalSupply();
				const { logs } = await this.token.burnFrom(owner, 100e18, { from: burner });
				this.logs = logs;
				this.initialSupply = initialSupply;
			});

			it('burns the requested amount', async function () {
				const balance = await this.token.balanceOf(owner);
				balance.should.be.bignumber.equal(400e18);
			});

			it('totalSupply should be less after burning', async function () {
				const supply = await this.token.totalSupply();
				assert.isTrue(supply < this.initialSupply);
			});

			it('decrements allowance', async function () {
				const allowance = await this.token.allowance(owner, burner);
				allowance.should.be.bignumber.equal(200e18);
			});

			it('emits a burn event', async function () {
				const event = await testUtil.inLogs(this.logs, 'Burn');
				event.args._burner.should.eq(owner);
				event.args._value.should.be.bignumber.equal(100e18);
			});

			it('emits a transfer event', async function () {
				const event = await testUtil.inLogs(this.logs, 'Transfer');
				event.args._from.should.eq(owner);
				event.args._to.should.eq(ZERO_ADDRESS);
				event.args._value.should.be.bignumber.equal(100e18);
			});
		});

		describe('when the given amount is greater than the balance of the sender', function () {

			const newAmount = 501e18;
			it('reverts', async function () {
				await this.token.unpause({ from: owner });
				await this.token.mint(this.token.address, 500e18, { from: owner });
				await this.token.buy({ from: owner, value: 500 });
				await this.token.approve(burner, newAmount, { from: owner });
				await testUtil.assertRevert(this.token.burnFrom(owner, newAmount, { from: burner }));
			});
		});

		describe('when the given amount is greater than the allowance', function () {
			const newAmount = 100;
			it('reverts', async function () {
				await this.token.unpause({ from: owner });
				await this.token.mint(this.token.address, 500e18, { from: owner });
				await this.token.buy({ from: owner, value: 500 });
				await this.token.approve(burner, newAmount - 1, { from: owner });
				await testUtil.assertRevert(this.token.burnFrom(owner, newAmount, { from: burner }));
			});
		});
	});
});