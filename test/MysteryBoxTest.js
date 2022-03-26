const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
var BigNumber = require('big-number');

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

    describe("Make Box", async () => {
        //it("Purchase Price Insufficient", async () => {
        //    let v1 = await eth('0.09');
        //    await truffleAssert.reverts(mBoxInstance.makeBox(1, accounts[1], {from: accounts[1], value: v1})
        //    , "0.1 ether is needed to make the premium box");
        //})
/*
        it("Check NFT Listing", async () => {
            let o1 = await mBoxInstance.getOwnedInstance({from: accounts[0]});
            assert.strictEqual(o1.toNumber(), 1);
        })*/

        it("Premium Box Made", async () => {
            //let v2 = await eth('0.11');
            await testNFTInstance.mint(ownedInstance.address);
            await testNFTInstance.mint(ownedInstance.address);
            await testNFTInstance.mint(ownedInstance.address);
            await ownedInstance.add(eth('0.035'), testNFTInstance.address, 0, false, {from: accounts[0]});
            await ownedInstance.add(eth('0.038'), testNFTInstance.address, 1, false, {from: accounts[0]});
            await ownedInstance.add(eth('0.040'), testNFTInstance.address, 2, true, {from: accounts[0]});
            let m1 = await mBoxInstance.makeBox(1, accounts[1], {from: accounts[1]})
            //truffleAssert.passes(m1);
            truffleAssert.eventEmitted(m1, "boxMade");
        })
    })
    
    // Unit test 1: Testing MakeBox (make sure event emitted)
        // Price is within range
    // Unit test 2: Testing transfer (make sure event emitted)
        // Insert 0.4 ether and make transfer fails
        // Make sure box is transferred to new owner
    // Unit test 3: Testing OpenBox (make sure event emitted)
        // Make sure other ppl cannot open what doesnt belong to them
        // Cannot open the same box twice
})