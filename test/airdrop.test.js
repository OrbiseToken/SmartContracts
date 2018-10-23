const testUtil = require("./utils/test.util");

const ERC20Extended = artifacts.require('../contracts/erc20/ERC20Extended.sol');
const ERC20ExtendedData = artifacts.require('../contracts/erc20/data/ERC20ExtendedData.sol');
const Ledger = artifacts.require('../contracts/ledger/Ledger.sol');
const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');
const Airdrop = artifacts.require('../contracts/airdrop/AirDrop.sol');

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-bignumber')(BigNumber))
  .should();

contract('Airdrop', function ([_, owner, one, two, three, four, five, six, seven]) {
    const sufficientMintAmount = 42e18;
    const insufficientMintAmount = 41e18;
    const airdropAmount = 6e18;

    beforeEach(async function () {
        const tokenStorage = await ERC20ExtendedData.new({ from: owner });
		const ledger = await Ledger.new({ from: owner });
		this.whitelist = await WhitelistData.new({ from: owner });
		const price = 1;
		this.token = await ERC20Extended.new(tokenStorage.address, ledger.address, this.whitelist.address, { from: owner });
		await this.token.setPrices(price, price, { from: owner });
		await tokenStorage.setContractAddress(this.token.address, { from: owner });
        await ledger.setContractAddress(this.token.address, { from: owner });

        this.airdrop = await Airdrop.new({ from: owner });
    });
    
    describe('airdrop', async function () {
        it('correctly send tokens to multiple addresses', async function () {
            // Arrange
            await this.token.mint(this.airdrop.address, sufficientMintAmount, { from: owner });

            // Assert
            (await this.token.balanceOf(this.airdrop.address)).should.be.bignumber.equal(sufficientMintAmount);
            
            // Act
            await this.token.unpause({ from: owner });
            await this.airdrop.airdrop(this.token.address, airdropAmount, [one,two,three,four,five,six,seven], { from: owner });

            // Assert
            (await this.token.balanceOf(one)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(two)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(three)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(four)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(five)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(six)).should.be.bignumber.equal(airdropAmount);
            (await this.token.balanceOf(seven)).should.be.bignumber.equal(airdropAmount);

            (await this.token.balanceOf(this.airdrop.address)).should.be.bignumber.equal(0);
        });

        it('Should revert when an empty array is passed', async function () {
            const airdrop = this.airdrop.airdrop(this.token.address,airdropAmount, []);

            await testUtil.assertRevert(airdrop);
        });

        it('Should revert when airdrop contract does not have enough tokens to transfer to specified addresses', async function () {
            // Arrange
            await this.token.mint(this.airdrop.address, insufficientMintAmount, { from: owner });

            // Assert
            (await this.token.balanceOf(this.airdrop.address)).should.be.bignumber.equal(insufficientMintAmount);

            // Act
            await this.token.unpause({ from: owner });
            const airdrop = this.airdrop.airdrop(this.token.address, airdropAmount, [one,two,three,four,five,six,seven], { from: owner });

            // Assert
            await testUtil.assertRevert(airdrop);
        });
    });
});