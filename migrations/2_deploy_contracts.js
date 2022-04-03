var SimpleStorage = artifacts.require("./SimpleStorage.sol");
const MysteryNFT = artifacts.require("./MysteryNFT.sol");
const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const MysteryBox = artifacts.require("./MysteryBox.sol");
const testNFT = artifacts.require("./SampleNFT.sol");
const MysteryToken = artifacts.require("./MysteryToken.sol");
const PurchaseNFT = artifacts.require("./PurchaseNFT.sol");
const MysteryStake = artifacts.require("./MysteryStaking.sol");

module.exports = (deployer, network, accounts) => {
	deployer.deploy(SimpleStorage).then(() => {
		return deployer.deploy(MysteryNFT).then(() => {
			return deployer.deploy(ownedNFTs).then(() => {
				return deployer.deploy(testNFT). then(() => {
					return deployer.deploy(MysteryBox, ownedNFTs.address).then(() => {
						return deployer.deploy(MysteryToken).then(() => {
							return deployer.deploy(PurchaseNFT, MysteryToken.address, ownedNFTs.address).then(() => {
								return deployer.deploy(MysteryStake). then(() => {
									return deployer.deploy(MysteryBox, ownedNFTs.address, MysteryStake.address, MysteryNFT.address);
								})
							})
						})
					})
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