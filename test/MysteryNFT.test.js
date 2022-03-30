const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { cp } = require("fs");

const MysteryNFT = artifacts.require("./MysteryNFT.sol");

contract("MysteryNFT", (accounts) => {
  let contract;

  before(async () => {
    contract = await MysteryNFT.deployed();
  });

  describe("deployment", async () => {
    it("deployment test", async () => {
      const address = contract.address;
      assert.notEqual(address, "");
      assert.notEqual(address, 0x0);
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });
    it("has name", async () => {
      const name = await contract.name();
      assert.equal(name, "MysteryNFT");
    });
    it("has symbol", async () => {
      const symbol = await contract.symbol();
      assert.equal(symbol, "MYSTNFT");
    });
  });

  describe("minting", async () => {
    it("create new token", async () => {
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

  describe("indexing", async () => {
    it("rarity check", async () => {
      await contract.mint(1, []);
      await contract.mint(1, []);
      await contract.mint(2, ['0x111122223333444455556666777788889999aAaa']);
      const totalSupply = await contract.totalSupply();

      let result = [];

      for (var i = 0; i < totalSupply; i++) {
        const id = await contract.getRarity(i);
        result.push(id);
      }

      let expected = [0, 1, 1, 2];
      assert.equal(result.join(","), expected.join(","));
    });

    it("contents check", async () => {
      const totalSupply = await contract.totalSupply();

      let result = [];

      for (var i = 0; i < totalSupply; i++) {
        const id = await contract.getContents(i);
        result.push(id);
      }

      let expected = [[],[],[],['0x111122223333444455556666777788889999aAaa']];
      assert.equal(result.join(","), expected.join(","));
    });
  });

  
});
