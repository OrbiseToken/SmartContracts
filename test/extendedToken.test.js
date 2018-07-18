const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const LedgerData = artifacts.require('../contracts/ledger/data/LedgerData.sol');

contract('ERC20Extended', function ([owner, anotherAccount, wallet]) {
  
    beforeEach(async function () {
        const randomAddressForWallet = 0x5aeda56215b167893e80b4fe645ba6d5bab767de;
        const tokenStorage = await ERC20ExtendedData.new({from: owner});
        const ledgerData = await LedgerData.new({from: owner});
        const ledger = await Ledger.new(ledgerData.address, {from: owner});
        const price = await web3.toWei('1', 'ether');
        this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, price, price, randomAddressForWallet, {from: owner});
        await tokenStorage.setContractAddress(this.token.address, {from: owner});
        await ledger.setContractAddress(this.token.address, {from: owner});
        await ledgerData.setContractAddress(ledger.address, {from: owner});
    });

    it('token Should have a fallback function', async function () {
        await this.token.sendTransaction({from: anotherAccount, value: 1});
        const balance = await this.token.getContractBalance();

        assert.equal(balance, 1);
    });

    describe('token Should have buy, sell and wallet setting functions', function () {
        it('setPrices Should allow owners to set the buy price for the token', async function () {
            const buyPrice = 2;
            const sellPrice = 5;

            const success = await this.token.setPrices(sellPrice, buyPrice, { from: owner });
            
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
            await this.token.unpause({ from: owner});
            await this.token.mint(this.token.address, 1, { from: owner });
            const { logs } = await this.token.buy({ from: anotherAccount, value: 100});
            this.logs = logs;
        });

        it('buy Should allow accounts to give ether in exchange for tokens', async function () {
            const balance = await this.token.balanceOf(anotherAccount);
            assert.equal(balance, 100);
        });

        it('buy Should emit a Transfer event when called', async function () {
            assert.equal(this.logs[0].event, 'Transfer');
            assert.equal(this.logs[0].args._from, this.token.address);
            assert.equal(this.logs[0].args._to, anotherAccount);
            assert.equal(this.logs[0].args._value, 100);
        });

        it('sell Should allow accounts to give tokens in exchange for ether', async function () {
            await this.token.sell(100, { from: anotherAccount});
            const balance = await this.token.balanceOf(anotherAccount);
            const contractBalance = await this.token.balanceOf(this.token.address);
            
            assert.equal(balance, 0);
            assert.equal(contractBalance, web3.toWei('1', 'ether'));
        });

        it('sell Should emit a Transfer event when called', async function () {
            const { logs } = await this.token.sell(100, { from: anotherAccount });
            
            assert.equal(logs[0].event, 'Transfer');
            assert.equal(logs[0].args._from, anotherAccount);
            assert.equal(logs[0].args._to, this.token.address);
            assert.equal(logs[0].args._value, 100);
        });
    });

    it('withdraw Should allow owners to withdraw from token contract', async function () {
        await this.token.sendTransaction({ from: anotherAccount, value: 100});
        const bal = await this.token.getContractBalance();
        await this.token.withdraw(100, { from: owner });
        const balanceAfterWithdraw = await this.token.getContractBalance();
        assert(balanceAfterWithdraw, 0);
    });

    it('nonEtherPurchaseTransfer Should allow owners to transfer tokens to specified account without ether', async function () {
        await this.token.unpause({ from: owner });
        await this.token.mint(this.token.address, 1, { from: owner });
        await this.token.nonEtherPurchaseTransfer(anotherAccount, 100, { from: owner });
        const anotherBalance = await this.token.balanceOf(anotherAccount);

        assert.equal(anotherBalance, 100);
    });
});