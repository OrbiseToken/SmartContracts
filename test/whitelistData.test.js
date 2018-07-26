const assertRevert = require('./utils/test.util.js').assertRevert;

const WhitelistData = artifacts.require('../contracts/whitelist/WhitelistData.sol');
const sampleId = "0x0118f27c6d9da217a74e5b50c531aa6dc8ed57bb040e1b700000000000000001";
const emptyId = "0x0000000000000000000000000000000000000000000000000000000000000000";
const emptyAddress = "0x0000000000000000000000000000000000000000";

const ids = [
    "0xfcf016cd162da6903cba6503a2cbc7e3ca94a68af690ed4aba2fbc26f7351b30",
    "0x06016843ce172636f220dfda35dcd9f57a0efd073c6af6433b7672c06e61fd44",
    "0x62c91a9b1ff61f79ad8bd2802fa74ad6932464423743b0172584c2a23d79c8d5",
    "0x7f0003970042e32222132e33c3b1e52189722ba098afbdc42fc482871e848b14",
    "0xbcd1990a5c6c56c58f56c0392d73be1dea5000cd474f194ce10c7daacaaa3ac3",
    "0x004cfaa35c4f3c38af4a65376596f588a893bffca7bffbd507885d7079000c0d",
    "0xcdf6449477b3c9d5622ac1573595af034faf3e1522c43ae61d5050434c9479b2",
    "0x05e153777a1e6bb2fda5f39fe8fbd9fe63d82619614c9c938d3c7771e6ee7ab0",
    "0x54c904971724ee76f9470d85be02679956fff3637231f25f0ab9e34aad05f18f",
    "0x81427b636572c9d57985e14f9649a4c39ac6e352e085854aa420b7a35457c042",
]

const addresess = [
    "0x6a0fc419ffb833dfc9949fee53ce836abc744ce9",
    "0x9268a61846571ebf1665fe0fa37395438568782b",
    "0x932c5d946fa1c1c8b9757a2dfa2417a9cde4d0ff",
    "0x6cc127251d6f6affed1ecfe7d5e2408b200ea18d",
    "0x53a0f816c2ba51565cdc850ac314c42cb33cbfc8",
    "0x38c7ea86c8235b0cfccfb91153259e85353cd202",
    "0x111a99859a8b113251d899f0675607766736ffda",
    "0x911a99859a8baa32511899f0675607711736ffaa",
    "0x131a99859a8bfa3251d899f06aad121f6736ffad",
    "0x131a99a59a1bfa3f1d892f06156077614136ff89",
]

contract('WhitelistData', ([owner, another, other, bot]) => {

	beforeEach(async () => {
		this.whitelist = await WhitelistData.new();
	});

	it('addSingleCustomer Should revert When not invoked from owner', async () => {
        const add = this.whitelist.addSingleCustomer(other, sampleId, { from: another });
        await assertRevert(add);
	});

	it('addSingleCustomer Should revert When invoked with an empty `_customer` parameter', async () => {
        const add = this.whitelist.addSingleCustomer(emptyAddress, sampleId, { from: owner });
        await assertRevert(add);
        });
    
	it('addSingleCustomer Should revert When invoked with an empty `_id` parameter', async () => {
        const add = this.whitelist.addSingleCustomer(other, emptyId, { from: owner });
        await assertRevert(add);
	});

	it('addSingleCustomer Should raise `LogNewCustomer` event with exact arguments When valid arguments are passed', async () => {
        const { logs } = await this.whitelist.addSingleCustomer(other, sampleId, { from: owner});

        assert.equal(logs[0].event, 'LogNewCustomer');
        assert.equal(logs[0].args.customer, other);
        assert.equal(logs[0].args.id, sampleId);
	});

	it('addSingleCustomer Should set exact `_id` to `kycId` map When valid arguments are passed', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const id = await this.whitelist.kycId(other);
        assert.equal(id, sampleId);
	});

	it('addSingleCustomer Should raise `LogCustomerUpdate` event with exact arguments When the `_customer` already exists and the new `_id` is higher level', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const higherId = sampleId.replace(/.$/, "2");

        const { logs } = await this.whitelist.addSingleCustomer(other, higherId, { from: owner});

        assert.equal(logs[0].event, 'LogCustomerUpdate');
        assert.equal(logs[0].args.customer, other);
        assert.equal(logs[0].args.id, higherId);
	});

	it('addSingleCustomer Should set exact `_id` to `kycId` map When the `_customer` already exists and the new `_id` is higher level', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const higherId = sampleId.replace(/.$/, "2");

        await this.whitelist.addSingleCustomer(other, higherId, { from: owner});
       
        const id = await this.whitelist.kycId(other);
        assert.equal(id, higherId);
	});

	it('addSingleCustomer Should keep the existing `_id` in the `kycId` map When the `_customer` already exists and the new `_id` is lower level', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const lowerId = sampleId.replace(/.$/, "0");
        await this.whitelist.addSingleCustomer(other, lowerId, { from: owner});
       
        const id = await this.whitelist.kycId(other);
        assert.equal(id, sampleId);
	});

	it('addManyCustomers Should revert When not invoked from owner', async () => {
        const add = this.whitelist.addManyCustomers(addresess, ids, { from: another });
        await assertRevert(add);
	});

	it('addManyCustomers Should revert When `_customers` length is not equal to `_ids` length', async () => {
        const oneFewer = addresess.slice();
        await oneFewer.pop();

        const add = this.whitelist.addManyCustomers(oneFewer, ids, { from: owner });
        await assertRevert(add);
	});

	it('addManyCustomers Should revert When `_customers` length is greater than 128', async () => {
        let tooManyAddresses = addresess;
        for (let i = 0; i < 14; i++) {
            tooManyAddresses = tooManyAddresses.concat(addresess);
        }

        let tooManyIds = ids;
        for (let i = 0; i < 14; i++) {
            tooManyIds = tooManyIds.concat(ids);
        }

        const add = this.whitelist.addManyCustomers(tooManyAddresses, tooManyIds, { from: owner });
        await assertRevert(add);
	});

	it('addManyCustomers Should set exact set of `_customers` according to their `_ids` in the `kycId` map When valid arguments are passed', async () => {
        await this.whitelist.addManyCustomers(addresess, ids, { from: owner });
        for (let i = 0; i < addresess.length; i++) {
            const id = await this.whitelist.kycId(addresess[i]);
            assert.equal(id, ids[i]);
        }
	});

	it('deleteCustomer Should revert When not invoked from owner', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const del = this.whitelist.deleteCustomer(other, { from: another });

        await assertRevert(del);
	});

	it('deleteCustomer Should revert When invoked with an empty `_customer` parameter', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const del = this.whitelist.deleteCustomer(emptyAddress, { from: owner });

        await assertRevert(del);
	});

	it('deleteCustomer Should raise `LogCustomerDeleted` event with exact arguments When valid arguments are passed', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const { logs } = await this.whitelist.deleteCustomer(other, { from: owner });

        assert.equal(logs[0].event, 'LogCustomerDeleted');
        assert.equal(logs[0].args.customer, other);
        assert.equal(logs[0].args.id, sampleId);
	});

	it('deleteCustomer Should delete existing `_customer` from the `kycId` map When valid arguments are passed', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        await this.whitelist.deleteCustomer(other, { from: owner });

        const id = await this.whitelist.kycId(other);
        assert.equal(id, 0);
    });
        
    it('addSingleCustomer Should revert when not invoked by bot or owner', async () => {
        const add = this.whitelist.addSingleCustomer(other, sampleId, { from: bot });
        await assertRevert(add);
    });

    it('addSingleContract Should work as intended when invoked by bot', async () => {
        await this.whitelist.setBot(bot, true, { from: owner });
        await this.whitelist.addSingleCustomer(other, sampleId, { from: bot });

        const id = await this.whitelist.kycId(other);
        assert.equal(id, sampleId);
    });

    it('addManyCustomers Should revert when not invoked by bot or owner', async () => {
        const add = this.whitelist.addManyCustomers(addresess, ids, { from: bot });
        await assertRevert(add);
    });

    it('addManyCustomers Should work as intended when invoked by bot', async () => {
        await this.whitelist.setBot(bot, true, { from: owner });
        await this.whitelist.addManyCustomers(addresess, ids, { from: bot });
        for (let i = 0; i < addresess.length; i++) {
            const id = await this.whitelist.kycId(addresess[i]);
            assert.equal(id, ids[i]);
        }
    });

    it('deleteCustomer Should revert when not invoked by bot or owner', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        const del = this.whitelist.deleteCustomer(other, { from: bot });
        await assertRevert(del);
    });

    it('deleteCustomer Should work as intended when invoked by bot', async () => {
        await this.whitelist.addSingleCustomer(other, sampleId, { from: owner });
        await this.whitelist.setBot(bot, true, { from: owner });
        await this.whitelist.deleteCustomer(other, { from: bot });

        const id = await this.whitelist.kycId(other);
        assert.equal(id, false);
    });    
});
