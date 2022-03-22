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
      const result = await contract.mint(123);
      //number of tokens that exist
      const totalSupply = await contract.totalSupply();
      assert.equal(totalSupply, 1);

      const event = result.logs[0].args;
      assert.equal(event.tokenId.toNumber(), 123, "id correct");
      assert.equal(event.from, 0x0, "from correct");
      assert.equal(event.to, accounts[0], "to correct");
    });
  });

  describe("indexing", async () => {
    it("list tokens", async () => {
    //   await contract.mint(123);
      await contract.mint(234);
      await contract.mint(345);
      await contract.mint(456);
      const totalSupply = await contract.totalSupply();

      let result = [];

      for (var i = 0; i < totalSupply; i++) {
        const id = await contract.tokenId(i);
        result.push(id);
      }
      
      let expected = [123, 234, 345, 456];
      assert.equal(result.join(","), expected.join(","));
    });
  });

  describe("user owns", async ()=>{
      
  })
});