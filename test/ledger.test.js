const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');

contract('ERC20Extended_ledger', function ([owner]) {

    beforeEach(async function () {
		const randomAddressForWallet = 0x5aeda56215b167893e80b4fe645ba6d5bab767de;
		const tokenStorage = await ERC20ExtendedData.new({from: owner});
		this.ledger = await Ledger.new({from: owner});
		const price = await web3.toWei('1', 'ether');
		this.token = await ERC20Extended.new(tokenStorage.address, this.ledger.address, price, price, randomAddressForWallet, {from: owner});
		await tokenStorage.setContractAddress(this.token.address, {from: owner});
		await this.ledger.setContractAddress(this.token.address, {from: owner});
	});

    describe('ledger should allow past transactions to be accessed by index', function () {
        beforeEach(async function () {
            await this.token.unpause({ from: owner });
            await this.token.mint(this.token.address, 1, { from: owner });
            const { logs } = await this.token.buy({ from: owner, value: 100});
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