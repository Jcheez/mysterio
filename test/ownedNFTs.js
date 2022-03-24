const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { cp } = require("fs");

const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const MysteryNFT = artifacts.require("./MysteryNFT.sol");

contract("OwnedNFTs", (accounts) => {

    before(async () => {
        ownedInstance = await ownedNFTs.deployed();
        testNFTInstance = await MysteryNFT.deployed();
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