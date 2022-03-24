const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { cp } = require("fs");

const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const testNFTs = artifacts.require("./testNFTs.sol")

contract("OwnedNFTs", (accounts) => {

    before(async () => {
        ownedInstance = await ownedNFTs.deployed();
        testNFTInstance = await testNFTs.deployed();
        testNFT1 = testNFTInstance.create("test1", "t1")
        testNFT2 = testNFTInstance.create("test2", "t2")
        testNFT3 = testNFTInstance.create("test3", "t3")
        testNFT4 = testNFTInstance.create("test4", "t4")
        testNFT5 = testNFTInstance.create("test5", "t5")
    });

    it("Adding NFT to ownedInstance", async () => {
        let add = await ownedInstance.add(123, testNFT1.address, {from: accounts[0]})
        let price = await ownedInstance.getPrices(0);
        assert.strictEqual(
            price,
            123,
            "Failed to add NFT"
        )
    })

})