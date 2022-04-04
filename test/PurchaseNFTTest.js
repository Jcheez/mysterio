const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { expectRevert, expectEvent, BN } = require('@openzeppelin/test-helpers');


const purchaseNFT = artifacts.require("./PurchaseNFT.sol");
const testNFT = artifacts.require("./SampleNFT.sol");

contract("purchaseNFTs", (accounts) => {
    let contract;
    
    before(async () => {
        purchaseInstance = await purchaseNFT.deployed();
        testInstance = await testNFT.deployed();
        

    });

    describe("Listing NFT test", async () => {
   
        it('Listing of NFT', async () => {
            await testInstance.mint(purchaseInstance.address);

            const l1 = await purchaseInstance.listNFT(testInstance.address, new BN(0), new BN(1000), {from: accounts[0]});
            expectEvent(l1, 'Listed', {
                listingId: new BN(1), 
                seller: accounts[0],
                token: testInstance.address, 
                tokenId: new BN(0), 
                price: new BN(1000)
            });

            return testInstance.ownerOf(new BN(0)).then(owner => {
                assert.equal(owner, purchaseInstance.address, "Contract has to be the new owner of the NFT instance" )
            });
        });

        it('NFT stored in different listing', async () => {
            await testInstance.mint(purchaseInstance.address);
            await testInstance.mint(purchaseInstance.address);
            const l1 = await purchaseInstance.listNFT(testInstance.address, new BN(1), new BN(1000), {from: accounts[0]});
            const l2 = await purchaseInstance.listNFT(testInstance.address, new BN(2), new BN(1000), {from: accounts[1]});
            expectEvent(l1, 'Listed', {
                listingId: new BN(2), 
                seller: accounts[0],
                token: testInstance.address, 
                tokenId: new BN(1), 
                price: new BN(1000)
            });
            expectEvent(l2, 'Listed', {
                listingId: new BN(3), 
                seller: accounts[1],
                token: testInstance.address, 
                tokenId: new BN(2), 
                price: new BN(1000)
            });

        })

        it("Seller cannot be buyer" , async () => {
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[0], value: 1000}), 'Buyer cannot be the seller of the NFT')
        });

        it("Cannot buy NFT due to insufficient funds" , async () => {
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[3], value: 100}), 'Not enough money')
        });

        it("Buy NFT", async () => {
            const b1 = await purchaseInstance.buyNFT(new BN(1), {from: accounts[3], value: 1000});
            expectEvent(b1, 'Bought', {
                listingId: new BN(1),
                buyer: accounts[3],
                token: testInstance.address,
                tokenId: new BN(0),
                price: new BN(1000)
            });

            return testInstance.ownerOf(new BN(0)).then(owner => {
                assert.equal(owner, accounts[3], "Buyer must be the new owner of the NFT")
            })
        })

        it("Sold NFT cannot be bought", async () => {
            return expectRevert(purchaseInstance.buyNFT(new BN(1), {from: accounts[3], value: 1000}), 'Listing is not available anymore')
        })


    });
    
})