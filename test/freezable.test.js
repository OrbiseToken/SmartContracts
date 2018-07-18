const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const LedgerData = artifacts.require('../contracts/ledger/data/LedgerData.sol');

contract('ERC20Extended_freezable', function ([owner, frozen, anotherAccount]) {
  
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

    describe('as a basic freezable token', function () {
        it('accounts Should not be frozen by default', async function () {
            const isFrozen = await this.token.isAccountFrozen(frozen);
            assert.equal(isFrozen, false);
        });

        it('freezeAccount Should only be accessible by owners', async function () {
            const isFrozen = this.token.freezeAccount(frozen, true, {from: anotherAccount});
            await testUtil.assertRevert(isFrozen);
        });

        describe('when freezing account', function () {
            beforeEach(async function () {
                const { logs } = await this.token.freezeAccount(frozen, true, {from: owner});
                this.logs = logs;
            });

            it('freezeAccount Should freeze accounts', async function () {
                const isFrozen = await this.token.isAccountFrozen(frozen);
                assert.equal(isFrozen, true);
            });

            it('freezeAccount Should allow owner to unfreeze accounts', async function () {
                await this.token.freezeAccount(frozen, false, {from: owner});
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
                await this.token.mint(this.token.address, 1, {from: owner});
                const purchase = this.token.buy({from: frozen, value: 1});

                await testUtil.assertThrow(purchase);
            });
        });
    });
});