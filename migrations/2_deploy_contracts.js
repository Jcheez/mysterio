var SimpleStorage = artifacts.require("./SimpleStorage.sol");
const MysteryNFT = artifacts.require("MysteryNFT");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(SimpleStorage);
  deployer.deploy(MysteryNFT);
};
