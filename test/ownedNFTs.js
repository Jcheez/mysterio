const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const testNFT = artifacts.require("./SampleNFT.sol");


contract("OwnedNFTs", (accounts) => {

    before(async () => {
        ownedInstance = await ownedNFTs.deployed();
        testNFTInstance = await testNFT.deployed();
        await testNFTInstance.mint(ownedInstance.address);
    });

    describe("Adding", async () => {
        it("Adding NFT", async () => {
            let add = await ownedInstance.add(100, testNFTInstance.address, 0, true, {from: accounts[0]});
            truffleAssert.eventEmitted(add, "nftAdded", ev => {
                return ev.price.toNumber() === 100 && ev.tokenId.toNumber() === 0;
            });
        });
    
        it("Checking NFT is added in correct order", async () => {
            let add = await ownedInstance.add(200, testNFTInstance.address, 2, false, {from: accounts[0]});
            let price = await ownedInstance.getPrice(0, false, {from: accounts[0]});
            assert.strictEqual(
                price.toNumber(),
                200,
                "NFT not added correctly"
            );
        });
    });

    describe("Selling", async () => {
        it("Marking NFT is sold", async () => {
            let sell = await ownedInstance.sold(0, true, {from: accounts[0]});
            truffleAssert.eventEmitted(sell, "nftSold", ev => {
                return ev.price.toNumber() === 100 && ev.tokenId.toNumber() === 0;
            });
        });
    
        it("Error received when selling same NFT", async () => {
            await truffleAssert.reverts(
                ownedInstance.sold(0, true, {from: accounts[0]}),
                "NFT has already been sold"
            );
        });
    
        it("Error received when selling invalid NFT", async () => {
            await truffleAssert.reverts(
                ownedInstance.sold(10, true, {from: accounts[0]}),
                "Invalid Id inserted"
            );
        });
    });

    describe("Transferring", async () =>{
        it("Transferring out of contract", async () => {
            let transfer = await ownedInstance.remove(0, true, {from: accounts[0]});
            truffleAssert.eventEmitted(transfer, "nftTransfered", ev => {
                return ev.price.toNumber() === 100 && ev.tokenId.toNumber() === 0;
            })
        });

        it("Error received when transferring transferred NFT", async () => {
            await truffleAssert.reverts(
                ownedInstance.remove(0, true, {from: accounts[0]}),
                "NFT has already been transferred"
            )
        });

        it("Error received when transferring invalid NFT", async () => {
            await truffleAssert.reverts(
                ownedInstance.remove(10, true, {from: accounts[0]}),
                "Invalid Id inserted"
            )
        });

        it("Error received when transferring unsold NFT", async () => {
            await truffleAssert.reverts(
                ownedInstance.remove(0, false, {from: accounts[0]}),
                "NFT has not been sold"
            )
        });
    });

})