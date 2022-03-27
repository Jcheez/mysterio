const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const testNFT = artifacts.require("./SampleNFT.sol");
const MysteryBox = artifacts.require("./MysteryBox.sol");

function eth(n) {
    return web3.utils.toWei(n, 'ether');
}

contract("MysteryBox", (accounts) => {

    before(async () => {
        ownedInstance = await ownedNFTs.deployed();
        testNFTInstance = await testNFT.deployed();
        mBoxInstance = await MysteryBox.deployed();
        
    });

    describe("MysteryBox tests", async () => {
        it("Check NFT Listing", async () => {
            await testNFTInstance.mint(mBoxInstance.address);
            await testNFTInstance.mint(mBoxInstance.address);
            await ownedInstance.add(eth('0.035'), testNFTInstance.address, 0, false, {from: accounts[0]});
            await ownedInstance.add(eth('0.035'), testNFTInstance.address, 1, false, {from: accounts[0]});
            let o1 = await mBoxInstance.getOwnedInstance({from: accounts[0]});
            assert.strictEqual(o1.toNumber(), 2);
        })

        it("Purchase Price Insufficient", async () => {
            let v1 = await eth('0.09');
            await truffleAssert.reverts(mBoxInstance.transfer(1, accounts[1], {from: accounts[1], value: v1})
            , "0.1 ether is needed to make the premium box");
        })

        it("Premium Box Made & Transferred", async () => {
            await testNFTInstance.mint(mBoxInstance.address);
            await testNFTInstance.mint(mBoxInstance.address);
            await testNFTInstance.mint(mBoxInstance.address);
            await ownedInstance.add(eth('0.035'), testNFTInstance.address, 2, false, {from: accounts[0]});
            await ownedInstance.add(eth('0.038'), testNFTInstance.address, 3, false, {from: accounts[0]});
            await ownedInstance.add(eth('0.040'), testNFTInstance.address, 4, true, {from: accounts[0]});
            let v2 = await eth('0.11');
            let m1 = await mBoxInstance.transfer(1, accounts[1], {from: accounts[1], value: v2})
            truffleAssert.eventEmitted(m1, "boxMade");
            truffleAssert.eventEmitted(m1, "transferMade");
        })

        it("Opening Someone Else's Box", async () => {
            await truffleAssert.reverts(mBoxInstance.openBox(1, {from: accounts[3]}), "this box does not belong to you");
        })

        it("Opening Box", async () => {
            let v2 = await eth('0.11');
            let m1 = await mBoxInstance.transfer(1, accounts[2], {from: accounts[2], value: v2})
            let m2 = await mBoxInstance.openBox(2, {from: accounts[2]});
            truffleAssert.eventEmitted(m2, "boxOpen");
        })

        it("2nd opening of same Box", async () => {
            await truffleAssert.reverts(mBoxInstance.openBox(2, {from: accounts[2]}), "box has already been opened");
        })

    })
})