var SimpleStorage = artifacts.require("./SimpleStorage.sol");
const MysteryNFT = artifacts.require("./MysteryNFT.sol");
const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const MysteryBox = artifacts.require("./MysteryBox.sol");
const testNFT = artifacts.require("./SampleNFT.sol");

module.exports = (deployer, network, accounts) => {
	deployer.deploy(SimpleStorage).then(() => {
		return deployer.deploy(MysteryNFT).then(() => {
			return deployer.deploy(ownedNFTs).then(() => {
				return deployer.deploy(MysteryBox, ownedNFTs.address).then(() => {
					return deployer.deploy(testNFT);
				})
			})
		})
	});

	// Alternative way to deploy if somehow the above code fails
	// deployer.deploy(SimpleStorage);
	// deployer.deploy(MysteryNFT);
	// deployer.deploy(ownedNFTs).then(() => {
	// 	return deployer.deploy(MysteryBox, ownedNFTs.address);
	// });
};