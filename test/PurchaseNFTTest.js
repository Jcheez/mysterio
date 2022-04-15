const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { expectRevert, expectEvent, BN } = require('@openzeppelin/test-helpers');


const purchaseNFT = artifacts.require("./PurchaseNFT.sol");
const testNFT = artifacts.require("./SampleNFT.sol");
const MysteryStake = artifacts.require("./MysteryStaking.sol");


contract("purchaseNFTs", (accounts) => {
    let contract;
    
    before(async () => {
        purchaseInstance = await purchaseNFT.deployed();
        testInstance = await testNFT.deployed();
        mStakeInstance = await MysteryStake.deployed();
        

    });

    describe("Listing NFT test", async () => {

        it('Unable to list NFT as it is not approved', async () => {
            await testInstance.mint(accounts[0], {from: accounts[0]});
                return expectRevert(
                  purchaseInstance.listNFT(
                  testInstance.address,
                  new BN(0),
                  "19000000000000000",
                ), 'ERC721: transfer caller is not owner nor approved');
              });
        
   
        it('Listing of NFT', async () => {
            await testInstance.mint(accounts[0], {from: accounts[0]});
            await testInstance.approve(purchaseInstance.address, new BN(0), {from: accounts[0]})

            const l1 = await purchaseInstance.listNFT(testInstance.address, new BN(0), "19000000000000000", {from: accounts[0]});
            expectEvent(l1, 'Listed', {
                listingId: new BN(1), 
                seller: accounts[0],
                token: testInstance.address, 
                tokenId: new BN(0), 
                price: "19000000000000000"
            });

            return testInstance.ownerOf(new BN(0)).then(owner => {
                assert.equal(owner, purchaseInstance.address, "Contract has to be the new owner of the NFT instance" )
            });
        });

        it("Seller cannot be buyer" , async () => {
            await mStakeInstance.getMYST({from: accounts[0], value: 1000000000000000000});
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[0]}), 'Buyer cannot be the seller of the NFT')
        });

        it("Cannot buy NFT due to insufficient funds" , async () => {
            await mStakeInstance.getMYST({from: accounts[3], value: 10000000000000000});
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[3]}), 'Not enough money')
        });

        it("Buy NFT", async () => {
            await mStakeInstance.getMYST({from: accounts[3], value: 1000000000000000000});
            const b1 = await purchaseInstance.buyNFT(new BN(1), {from: accounts[3]});
            expectEvent(b1, 'Bought', {
                listingId: new BN(1),
                buyer: accounts[3],
                token: testInstance.address,
                tokenId: new BN(0),
                price: "19000000000000000"
            });

            return testInstance.ownerOf(new BN(0)).then(owner => {
                assert.equal(owner, accounts[3], "Buyer must be the new owner of the NFT")
            })
        })

        it("Sold NFT cannot be bought", async () => {
            await mStakeInstance.getMYST({from: accounts[3], value: 1000000000000000000});
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[3]}), 'Listing is not available anymore')
        })


    });
    
})

// minimum to get a myst token = 10000000000000000
// min myst token made = 1000000000000
// for insufficient funds, min price of NFT must be 1000000000001 
