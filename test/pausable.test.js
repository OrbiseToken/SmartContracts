const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_pausable', function ([_, owner, recipient, anotherAccount, bot]) {
	beforeEach(async function () {
		const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		const whitelist = await WhitelistData.new({ from: owner });
		const price = await web3.toWei('1', 'ether');
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, whitelist.address, { from: owner });
		await whitelist.addSingleCustomer(owner, '0xe9ce785086f5c3b748f71d481085ecfed6e8b27dde50ff827a68cda21a68abdb', { from: owner });
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
		await ledger.setContractAddress(this.token.address, { from: owner });
	});

	describe('pause', function () {
		describe('when the sender is the token owner', function () {
			const from = owner;

			describe('when the token is unpaused', function () {
				it('pauses the token', async function () {
					await this.token.pause({ from });

					const paused = await this.token.paused();
					assert.equal(paused, true);
				});

				it('emits a Pause event', async function () {
					const { logs } = await this.token.pause({ from });

					assert.equal(logs.length, 1);
					assert.equal(logs[0].event, 'Pause');
				});
			});
		});

		describe('when the sender is not the token owner nor bot', function () {
			const from = anotherAccount;

			it('reverts', async function () {
				await testUtil.assertRevert(this.token.pause({ from }));
			});
		});

		describe('when the sender is a bot', function () {
			let from;
			beforeEach(async function () {
				await this.token.setBot(bot, true, { from: owner });
				from = bot;
			});

			describe('when the token is unpaused', function () {
				it('pauses the token', async function () {
					await this.token.pause({ from });

					const paused = await this.token.paused();
					assert.equal(paused, true);
				});

				it('emits a Pause event', async function () {
					const { logs } = await this.token.pause({ from });

					assert.equal(logs.length, 1);
					assert.equal(logs[0].event, 'Pause');
				});
			});
		});
	});

	describe('unpause', function () {
		describe('when the sender is the token owner', function () {
			const from = owner;

			describe('when the token is paused', function () {
				beforeEach(async function () {
					await this.token.pause({ from });
				});

				it('unpauses the token', async function () {
					await this.token.unpause({ from });

					const paused = await this.token.paused();
					assert.equal(paused, false);
				});

				it('emits an Unpause event', async function () {
					const { logs } = await this.token.unpause({ from });

					assert.equal(logs.length, 1);
					assert.equal(logs[0].event, 'Unpause');
				});
			});
		});

		describe('when the sender is not the token owner', function () {
			const from = anotherAccount;

			it('reverts', async function () {
				await testUtil.assertRevert(this.token.unpause({ from }));
			});
		});
	});

	describe('pausable token', function () {
		const from = owner;

		describe('paused', function () {
			it('is paused after being paused', async function () {
				await this.token.pause({ from });
				const paused = await this.token.paused({ from });

				assert.equal(paused, true);
			});

			it('is not paused after being paused and then unpaused', async function () {
				await this.token.pause({ from });
				await this.token.unpause({ from });
				const paused = await this.token.paused();

				assert.equal(paused, false);
			});
		});

		describe('transfer', function () {
			beforeEach(async function () {
				await this.token.unpause({ from });
				await this.token.mint(this.token.address, 1, { from });
				await this.token.buy({ from: owner, value: 100 });
			});

			it('allows to transfer when unpaused', async function () {

				await this.token.transfer(recipient, 100, { from: owner });

				const senderBalance = await this.token.balanceOf(owner);
				assert.equal(senderBalance, 0);

				const recipientBalance = await this.token.balanceOf(recipient);
				assert.equal(recipientBalance, 100);
			});

			it('allows to transfer when paused and then unpaused', async function () {
				await this.token.pause({ from: owner });
				await this.token.unpause({ from: owner });

				await this.token.transfer(recipient, 100, { from: owner });

				const senderBalance = await this.token.balanceOf(owner);
				assert.equal(senderBalance, 0);

				const recipientBalance = await this.token.balanceOf(recipient);
				assert.equal(recipientBalance, 100);
			});

			it('reverts when trying to transfer when paused', async function () {
				await this.token.pause({ from: owner });

				await testUtil.assertRevert(this.token.transfer(recipient, 100, { from: owner }));
			});
		});

		describe('approve', function () {
			it('allows to approve when unpaused', async function () {
				await this.token.unpause({ from });
				await this.token.approve(anotherAccount, 40, { from: owner });

				const allowance = await this.token.allowance(owner, anotherAccount);
				assert.equal(allowance, 40);
			});

			it('allows to transfer when paused and then unpaused', async function () {
				await this.token.pause({ from: owner });
				await this.token.unpause({ from: owner });

				await this.token.approve(anotherAccount, 40, { from: owner });

				const allowance = await this.token.allowance(owner, anotherAccount);
				assert.equal(allowance, 40);
			});

			it('reverts when trying to transfer when paused', async function () {
				await this.token.pause({ from: owner });

				await testUtil.assertRevert(this.token.approve(anotherAccount, 40, { from: owner }));
			});
		});

		describe('transfer from', function () {
			beforeEach(async function () {
				await this.token.unpause({ from });
				await this.token.mint(this.token.address, 1, { from });
				await this.token.buy({ from: owner, value: 100 });
				await this.token.approve(anotherAccount, 50, { from: owner });
			});

			it('allows to transfer from when unpaused', async function () {
				await this.token.transferFrom(owner, recipient, 40, { from: anotherAccount });

				const senderBalance = await this.token.balanceOf(owner);
				assert.equal(senderBalance, 60);

				const recipientBalance = await this.token.balanceOf(recipient);
				assert.equal(recipientBalance, 40);
			});

			it('allows to transfer when paused and then unpaused', async function () {
				await this.token.pause({ from: owner });
				await this.token.unpause({ from: owner });

				await this.token.transferFrom(owner, recipient, 40, { from: anotherAccount });

				const senderBalance = await this.token.balanceOf(owner);
				assert.equal(senderBalance, 60);

				const recipientBalance = await this.token.balanceOf(recipient);
				assert.equal(recipientBalance, 40);
			});

			it('reverts when trying to transfer from when paused', async function () {
				await this.token.pause({ from: owner });

				await testUtil.assertRevert(this.token.transferFrom(owner, recipient, 40, { from: anotherAccount }));
			});
		});
	});
});