const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');

contract('ERC20Extended_mintable', function ([owner, anotherAccount]) {
	const minter = owner;

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

	describe('as a basic mintable token', function () {
		describe('minting finished', function () {
			describe('when the token minting is not finished', function () {
				it('returns false', async function () {
					const mintingFinished = await this.token.mintingFinished();
					assert.equal(mintingFinished, false);
				});
			});

			describe('when the token is minting finished', function () {
				beforeEach(async function () {
					await this.token.finishMinting({ from: owner });
				});

				it('returns true', async function () {
					const mintingFinished = await this.token.mintingFinished();
					assert.equal(mintingFinished, true);
				});
			});
		});

		describe('finish minting', function () {
			describe('when the sender is the token owner', function () {
				const from = owner;

				describe('when the token minting was not finished', function () {
					it('finishes token minting', async function () {
						await this.token.finishMinting({ from });

						const mintingFinished = await this.token.mintingFinished();
						assert.equal(mintingFinished, true);
					});

					it('emits a mint finished event', async function () {
						const { logs } = await this.token.finishMinting({ from });

						assert.equal(logs.length, 1);
						assert.equal(logs[0].event, 'MintFinished');
					});
				});
			});

			describe('when the sender is not the token owner', function () {
				const from = anotherAccount;

				describe('when the token minting was not finished', function () {
					it('reverts', async function () {
						await testUtil.assertRevert(this.token.finishMinting({ from }));
					});
				});

				describe('when the token minting was already finished', function () {
					beforeEach(async function () {
						await this.token.finishMinting({ from: owner });
					});

					it('reverts', async function () {
						await testUtil.assertRevert(this.token.finishMinting({ from }));
					});
				});
			});
		});

		describe('mint', function () {
			const amount = 100;

			describe('when the sender has the minting permission', function () {
				const from = minter;

				describe('when the token minting is not finished', function () {
					it('mints the requested amount', async function () {
						await this.token.mint(owner, amount, { from });

						const minted = await web3.toWei('100', 'ether');

						const balance = await this.token.balanceOf(owner);
						assert.equal(balance, minted);
					});

					it('emits a mint and a transfer event', async function () {
						const { logs } = await this.token.mint(owner, amount, { from });

						assert.equal(logs.length, 2);
						assert.equal(logs[0].event, 'Transfer');
						assert.equal(logs[1].event, 'Mint');
						assert.equal(logs[1].args._to, owner);
						assert.equal(logs[1].args._amount, web3.toWei('100', 'ether'));
					});
				});

				describe('when the token minting is finished', function () {
					beforeEach(async function () {
						await this.token.finishMinting({ from: owner });
					});

					it('reverts', async function () {
						await testUtil.assertRevert(this.token.mint(owner, amount, { from }));
					});
				});
			});

			describe('when the sender has not the minting permission', function () {
				const from = anotherAccount;

				describe('when the token minting is not finished', function () {
					it('reverts', async function () {
						await testUtil.assertRevert(this.token.mint(owner, amount, { from }));
					});
				});

				describe('when the token minting is already finished', function () {
					beforeEach(async function () {
						await this.token.finishMinting({ from: owner });
					});

					it('reverts', async function () {
						await testUtil.assertRevert(this.token.mint(owner, amount, { from }));
					});
				});
			});
		});
	});
});
