const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const MysteryNFT = artifacts.require("./MysteryNFT.sol");

contract("MysteryNFT", (accounts) => {
  let contract;

  before(async () => {
    contract = await MysteryNFT.deployed();
  });

  describe("Deployment", async () => {
    it("Deployment test", async () => {
      const address = contract.address;
      assert.notEqual(address, "");
      assert.notEqual(address, 0x0);
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });
    it("Has name 'MysteryNFT'", async () => {
      const name = await contract.name();
      assert.equal(name, "MysteryNFT");
    });
    it("Has symbol 'MYSTNFT'", async () => {
      const symbol = await contract.symbol();
      assert.equal(symbol, "MYSTNFT");
    });
  });

  describe("Minting", async () => {
    it("Create new NFT", async () => {
      const result = await contract.mint(0, []);
      //number of tokens that exist
      const totalSupply = await contract.totalSupply();
      assert.equal(totalSupply, 1);

      const event = result.logs[0].args;
      assert.equal(event.tokenId.toNumber(), 0, "id correct");
      assert.equal(event.from, 0x0, "from correct");
      assert.equal(event.to, accounts[0], "to correct");
    });
  });

  describe("Indexing", async () => {
    it("Rarity and contents check", async () => {
      await contract.mint(1, []);
      await contract.mint(1, []);
      await contract.mint(2, ["0x111122223333444455556666777788889999aAaa"]);
      const totalSupply = await contract.totalSupply();

      let rarityResult = [];
      let contentsResult = [];

      for (var i = 0; i < totalSupply; i++) {
        const rarity = await contract.getRarity(i);
        const contents = await contract.getContents(i);
        rarityResult.push(rarity);
        contentsResult.push(contents);
      }

      let rarityExpected = [0, 1, 1, 2];
      let contentsExpected = [
        [],
        [],
        [],
        ["0x111122223333444455556666777788889999aAaa"],
      ];

      assert.equal(rarityResult.join(","), rarityExpected.join(","));
      assert.equal(contentsResult.join(","), contentsExpected.join(","));
    });
  });

  describe("Ownership", async () => {
    it("Acc 0 owns all minted NFTs", async () => {
      const numberOwned = await contract.balanceOf(accounts[0]);
      assert.equal(numberOwned, 4);
    });

    it("Check idx and metadata of NFTs owned by Acc 0", async () => {
      const numberOwned = await contract.balanceOf(accounts[0]);
      let index = [];
      let rarity = [];
      let contents = [];
      for (let i = 0; i < numberOwned; i++) {
        const idx = await contract.tokenOfOwnerByIndex(accounts[0], i);
        index.push(idx);
        rarity.push(await contract.getRarity(idx));
        contents.push(await contract.getContents(idx));
      }

      let indexExpected = [0, 1, 2, 3];
      let rarityExpected = [0, 1, 1, 2];
      let contentsExpected = [
        [],
        [],
        [],
        ["0x111122223333444455556666777788889999aAaa"],
      ];

      assert.equal(index.join(","), indexExpected.join(","));
      assert.equal(rarity.join(","), rarityExpected.join(","));
      assert.equal(contents.join(","), contentsExpected.join(","));
    });

    // it("acc[1] owns nothing", async () => {
    //   const numberOwned = await contract.balanceOf(accounts[1]);
    //   assert.equal(numberOwned, 0);
    // });

    // it("transfer (not needed)", async () => {
    //   await contract.transferFrom(accounts[0], accounts[1], 0);
    //   const numberOwned = await contract.balanceOf(accounts[1]);
    //   assert.equal(numberOwned, 1);
    // });

    // it("testing tokenofownerbyindex", async () => {
    //   const numberOwned = await contract.balanceOf(accounts[0]);
    //   let rarity = [];
    //   //tokenofownerbyindex returns [1,2,3] (nfts owned by acc[0], not necessarily in that order)
    //   for (let i = 0; i < numberOwned; i++) {
    //     const idx = await contract.tokenOfOwnerByIndex(accounts[0], i);
    //     rarity.push(await contract.getRarity(idx));
    //   }
    //   rExpected = [2,1,1];
    //   rarity.sort((a,b)=>(b-a));
    //   assert.equal(rarity.join(","), rExpected.join(","));
    // });
  });
});
