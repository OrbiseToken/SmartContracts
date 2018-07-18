const Destructible = artifacts.require('../contracts/common/Destroyable.sol');

contract('Destructible', function (accounts) {
  it('should send balance to owner after destruction', async function () {
    const destructible = await Destructible.new({ from: accounts[0], value: web3.toWei('10', 'ether') });
    const initBalance = await web3.eth.getBalance(accounts[0]);
    await destructible.destroy({ from: accounts[0] });
    const newBalance = await web3.eth.getBalance(accounts[0]);
    assert.isTrue(newBalance > initBalance);
  });

  it('should send balance to recepient after destruction', async function () {
    const destructible = await Destructible.new({ from: accounts[0], value: web3.toWei('10', 'ether') });
    const initBalance = await web3.eth.getBalance(accounts[1]);
    await destructible.destroyAndSend(accounts[1], { from: accounts[0] });
    const newBalance = await web3.eth.getBalance(accounts[1]);
    assert.isTrue(newBalance.greaterThan(initBalance));
  });
});