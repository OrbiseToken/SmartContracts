const testUtil = require('./utils/test.util.js');

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const LedgerData = artifacts.require('../contracts/ledger/data/LedgerData.sol');

contract('ERC20Standard', function ([_, owner, recipient, anotherAccount]) {
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

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
    await this.token.unpause({from: owner});
    await this.token.mint(this.token.address, 1, {from: owner});
    await this.token.buy({from: owner, value: 100});
  });

  describe('total supply', function () {
    it('returns the total amount of tokens', async function () {
      const totalSupply = await this.token.totalSupply();

      assert.equal(totalSupply, web3.toWei('1', 'ether'));
    });
  });

  describe('balanceOf', function () {
    describe('when the requested account has no tokens', function () {
      it('returns zero', async function () {
        const balance = await this.token.balanceOf(anotherAccount);

        assert.equal(balance, 0);
      });
    });

    describe('when the requested account has some tokens', function () {
      it('returns the total amount of tokens', async function () {
        const balance = await this.token.balanceOf(owner);

        assert.equal(balance, 100);
      });
    });
  });

  describe('transfer', function () {
    describe('when the recipient is not the zero address', function () {
      const to = recipient;

      describe('when the sender does not have enough balance', function () {
        const amount = 101;

        it('reverts', async function () {
          await testUtil.assertRevert(this.token.transfer(to, amount, { from: owner }));
        });
      });

      describe('when the sender has enough balance', function () {
        const amount = 100;

        it('transfers the requested amount', async function () {
          await this.token.transfer(to, amount, { from: owner });

          const senderBalance = await this.token.balanceOf(owner);
          assert.equal(senderBalance, 0);

          const recipientBalance = await this.token.balanceOf(to);
          assert.equal(recipientBalance, amount);
        });

        it('emits a transfer event', async function () {
          const { logs } = await this.token.transfer(to, amount, { from: owner });

          assert.equal(logs[0].event, 'Transfer');
          assert.equal(logs[0].args._from, owner);
          assert.equal(logs[0].args._to, to);
          assert(logs[0].args._value.eq(amount));
        });
      });
    });

    describe('when the recipient is the zero address', function () {
      const to = ZERO_ADDRESS;

      it('reverts', async function () {
        await testUtil.assertRevert(this.token.transfer(to, 100, { from: owner }));
      });
    });
  });

  describe('approve', function () {
    describe('when the spender is not the zero address', function () {
      const spender = recipient;

      describe('when the sender has enough balance', function () {
        const amount = 100;

        it('emits an approval event', async function () {
          const { logs } = await this.token.approve(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(amount));
        });

        describe('when there was no approved amount before', function () {
          it('approves the requested amount', async function () {
            await this.token.approve(spender, amount, { from: owner });

            const allowance = await this.token.allowance(owner, spender);
            assert.equal(allowance, amount);
          });
        });

        describe('when the spender had an approved amount', function () {
          beforeEach(async function () {
            await this.token.approve(spender, 1, { from: owner });
          });

          it('approves the requested amount and replaces the previous one', async function () {
            await testUtil.assertRevert(this.token.approve(spender, amount, { from: owner }));
          });
        });
      });

      describe('when the sender does not have enough balance', function () {
        const amount = 101;

        it('emits an approval event', async function () {
          const { logs } = await this.token.approve(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(amount));
        });

        describe('when there was no approved amount before', function () {
          it('approves the requested amount', async function () {
            await this.token.approve(spender, amount, { from: owner });

            const allowance = await this.token.allowance(owner, spender);
            assert.equal(allowance, amount);
          });
        });

        describe('when the spender had an approved amount', function () {
          beforeEach(async function () {
            await this.token.approve(spender, 1, { from: owner });
          });

          it('approves the requested amount and replaces the previous one', async function () {
            await testUtil.assertRevert(this.token.approve(spender, amount, { from: owner }));
          });
        });
      });
    });

    describe('when the spender is the zero address', function () {
      const amount = 100;
      const spender = ZERO_ADDRESS;

      it('approves the requested amount', async function () {
        await this.token.approve(spender, amount, { from: owner });

        const allowance = await this.token.allowance(owner, spender);
        assert.equal(allowance, amount);
      });

      it('emits an approval event', async function () {
        const { logs } = await this.token.approve(spender, amount, { from: owner });

        assert.equal(logs[0].event, 'Approval');
        assert.equal(logs[0].args._owner, owner);
        assert.equal(logs[0].args._spender, spender);
        assert(logs[0].args._value.eq(amount));
      });
    });
  });

  describe('transfer from', function () {
    const spender = recipient;

    describe('when the recipient is not the zero address', function () {
      const to = anotherAccount;

      describe('when the spender has enough approved balance', function () {
        beforeEach(async function () {
          await this.token.approve(spender, 100, { from: owner });
        });

        describe('when the owner has enough balance', function () {
          const amount = 100;

          it('transfers the requested amount', async function () {
            await this.token.transferFrom(owner, to, amount, { from: spender });

            const senderBalance = await this.token.balanceOf(owner);
            assert.equal(senderBalance, 0);

            const recipientBalance = await this.token.balanceOf(to);
            assert.equal(recipientBalance, amount);
          });

          it('decreases the spender allowance', async function () {
            await this.token.transferFrom(owner, to, amount, { from: spender });

            const allowance = await this.token.allowance(owner, spender);
            assert(allowance.eq(0));
          });

          it('emits a transfer event', async function () {
            const { logs } = await this.token.transferFrom(owner, to, amount, { from: spender });

            assert.equal(logs[0].event, 'Transfer');
            assert.equal(logs[0].args._from, owner);
            assert.equal(logs[0].args._to, to);
            assert(logs[0].args._value.eq(amount));
          });
        });

        describe('when the owner does not have enough balance', function () {
          const amount = 101;

          it('reverts', async function () {
            await testUtil.assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
          });
        });
      });

      describe('when the spender does not have enough approved balance', function () {
        beforeEach(async function () {
          await this.token.approve(spender, 99, { from: owner });
        });

        describe('when the owner has enough balance', function () {
          const amount = 100;

          it('reverts', async function () {
            await testUtil.assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
          });
        });

        describe('when the owner does not have enough balance', function () {
          const amount = 101;

          it('reverts', async function () {
            await testUtil.assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
          });
        });
      });
    });

    describe('when the recipient is the zero address', function () {
      const amount = 100;
      const to = ZERO_ADDRESS;

      beforeEach(async function () {
        await this.token.approve(spender, amount, { from: owner });
      });

      it('reverts', async function () {
        await testUtil.assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
      });
    });
  });

  describe('decrease approval', function () {

    describe('when the spender is not the zero address', function () {
      const spender = recipient;

      describe('when the sender has enough balance', function () {
        const amount = 100;

        it('emits an approval event', async function () {
          await this.token.approve(spender, amount, { from: owner});
          const { logs } = await this.token.decreaseApproval(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(0));
        });

        describe('when the spender had an approved amount', function () {
          beforeEach(async function () {
            await this.token.approve(spender, amount + 1, { from: owner });
          });

          it('decreases the spender allowance subtracting the requested amount', async function () {
            await this.token.decreaseApproval(spender, amount, { from: owner });

            const allowance = await this.token.allowance(owner, spender);
            assert.equal(allowance, 1);
          });
        });
      });

      describe('when the sender does not have enough balance', function () {
        const amount = 101;

        it('emits an approval event', async function () {
          await this.token.approve(spender, amount, { from: owner});
          const { logs } = await this.token.decreaseApproval(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(0));
        });
      });
    });

    describe('when the spender is the zero address', function () {
      const amount = 100;
      const spender = ZERO_ADDRESS;

      it('decreases the requested amount', async function () {
        await this.token.approve(spender, amount, { from: owner});
        await this.token.decreaseApproval(spender, amount, { from: owner });

        const allowance = await this.token.allowance(owner, spender);
        assert.equal(allowance, 0);
      });

      it('emits an approval event', async function () {
        await this.token.approve(spender, amount, { from: owner});
        const { logs } = await this.token.decreaseApproval(spender, amount, { from: owner });

        assert.equal(logs[0].event, 'Approval');
        assert.equal(logs[0].args._owner, owner);
        assert.equal(logs[0].args._spender, spender);
        assert(logs[0].args._value.eq(0));
      });
    });
  });

  describe('increase approval', function () {
    const amount = 100;

    describe('when the spender is not the zero address', function () {
      const spender = recipient;

      describe('when the sender has enough balance', function () {
        it('emits an approval event', async function () {
          const { logs } = await this.token.increaseApproval(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(amount));
        });

        it('approves the requested amount', async function () {
          await this.token.increaseApproval(spender, amount, { from: owner });

          const allowance = await this.token.allowance.call(owner, spender);
          assert.equal(allowance.valueOf(), amount);
        });
      });

      describe('when the sender does not have enough balance', function () {
        const amount = 101;

        it('emits an approval event', async function () {
          const { logs } = await this.token.increaseApproval(spender, amount, { from: owner });

          assert.equal(logs[0].event, 'Approval');
          assert.equal(logs[0].args._owner, owner);
          assert.equal(logs[0].args._spender, spender);
          assert(logs[0].args._value.eq(amount));
        });

        it('approves the requested amount', async function () {
          await this.token.increaseApproval(spender, amount, { from: owner });

          const allowance = await this.token.allowance.call(owner, spender);
          assert.equal(allowance.valueOf(), amount);
        });
      });

      describe('when the spender had an approved amount', function () {
        beforeEach(async function () {
          await this.token.approve(spender, 1, { from: owner });
        });
  
        it('increases the spender allowance adding the requested amount', async function () {
          await this.token.increaseApproval(spender, amount, { from: owner });
  
          const allowance = await this.token.allowance(owner, spender);
          assert.equal(allowance, amount + 1);
        });
      }); 
    });

    describe('when the spender is the zero address', function () {
      const spender = ZERO_ADDRESS;

      it('approves the requested amount', async function () {
        await this.token.increaseApproval(spender, amount, { from: owner });

        const allowance = await this.token.allowance.call(owner, spender);
        assert.equal(allowance.valueOf(), amount);
      });

      it('emits an approval event', async function () {
        const { logs } = await this.token.increaseApproval(spender, amount, { from: owner });

        assert.equal(logs[0].event, 'Approval');
        assert.equal(logs[0].args._owner, owner);
        assert.equal(logs[0].args._spender, spender);
        assert(logs[0].args._value.eq(amount));
      });
    });
  });
});
