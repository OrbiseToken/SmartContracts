const testUtil = require('./utils/test.util.js');

const BigNumber = web3.BigNumber;
const SafeMathMock = artifacts.require('./utils/SafeMathMock.sol');

contract('SafeMath', () => {
  const MAX_UINT = new BigNumber('115792089237316195423570985008687907853269984665640564039457584007913129639935');

  before(async function () {
    this.safeMath = await SafeMathMock.new();
  });

  describe('add', function () {
    it('adds correctly', async function () {
      const a = new BigNumber(5678);
      const b = new BigNumber(1234);

      const result = await this.safeMath.add.call(a,b);
      assert.equal(result.valueOf(), a.plus(b));
    });

    it('throws an error on addition overflow', async function () {
      const a = MAX_UINT;
      const b = new BigNumber(1);

      await testUtil.assertJump(this.safeMath.add(a, b));
    });
  });

  describe('sub', function () {
    it('subtracts correctly', async function () {
      const a = new BigNumber(5678);
      const b = new BigNumber(1234);

      const result = await this.safeMath.sub.call(a, b);
      assert.equal(result.valueOf(), a.minus(b));
    });

    it('throws an error if subtraction result would be negative', async function () {
      const a = new BigNumber(1234);
      const b = new BigNumber(5678);

      await testUtil.assertJump(this.safeMath.sub(a, b));
    });
  });

  describe('mul', function () {
    it('multiplies correctly', async function () {
      const a = new BigNumber(1234);
      const b = new BigNumber(5678);

      const result = await this.safeMath.mul.call(a, b);
      assert.equal(result.valueOf(), a.times(b));
    });

    it('handles a zero product correctly', async function () {
      const a = new BigNumber(0);
      const b = new BigNumber(5678);

      const result = await this.safeMath.mul.call(a, b);
      assert.equal(result.valueOf(), a.times(b));
    });

    it('throws an error on multiplication overflow', async function () {
      const a = MAX_UINT;
      const b = new BigNumber(2);

      await testUtil.assertJump(this.safeMath.mul(a, b));
    });
  });

  describe('div', function () {
    it('divides correctly', async function () {
      const a = new BigNumber(5678);
      const b = new BigNumber(5678);

      const result = await this.safeMath.div.call(a, b);
      assert.equal(result.valueOf(), a.div(b));
    });

    it('throws an error on zero division', async function () {
      const a = new BigNumber(5678);
      const b = new BigNumber(0);

      await testUtil.assertJump(this.safeMath.div(a, b));
    });
  });
});
