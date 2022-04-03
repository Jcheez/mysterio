// const _deploy_contracts = require("../migrations/2_deploy_contracts");
// const truffleAssert = require("truffle-assertions");
// var assert = require("assert");

// const purchaseNFT = artifacts.require("./PurchaseNFT.sol");
// const testNFT = artifacts.require("./SampleNFT.sol");

// contract("PurchaseNFTs", (accounts) => {
    
//     before(async () => {
//         purchaseInstance = await purchaseNFT.deployed();
//         testInstance = await testNFT.deployed();
        
//         await testInstance.mint({from: accounts[1]});

//     });

//     describe("Purchasing NFT test", async () => {
//         it("Listing NFT", async () => {
//             await purchaseInstance.listNFT(testInstance.address, )
//         })
//     })
// })