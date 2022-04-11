const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const ERC20 = artifacts.require("./ERC20.sol");
const MysteryNFT = artifacts.require("./MysteryNFT")
const MysteryStaking = artifacts.require("./MysteryStaking.sol");


contract("MysteryStaking", (accounts) => {

    before(async () => {
        tokenInstance = await ERC20.deployed();
        nftInstance = await MysteryNFT.deployed();
        stakingInstance = await MysteryStaking.deployed();
    });

    describe("Provide accounts with $MYST", async () => {
        it("Getting $MYST", async () => {
            let getMYST = await stakingInstance.getMYST({from:accounts[0], value: 1E18});
            truffleAssert.eventEmitted(getMYST, "GetMYST");
        });
        it("Minting to other accounts", async () => {
            let getMYST = await stakingInstance.getMYST({from:accounts[1], value: 1E18});
            await stakingInstance.getMYST({from:accounts[2], value: 1E18});
            await stakingInstance.getMYST({from:accounts[3], value: 1E18});
            truffleAssert.eventEmitted(getMYST, "GetMYST");
        })
    });

    describe("Staking", async () => {
        it("Initial stake", async () => {
            let stake1 = await stakingInstance.stakeTokens(1E4, {from:accounts[0]});
            await stakingInstance.stakeTokens(1E4, {from:accounts[1]})
            await stakingInstance.stakeTokens(1E4, {from:accounts[2]})
            await stakingInstance.stakeTokens(1E4, {from:accounts[3]})
            truffleAssert.eventEmitted(stake1, "TokenStaked");
        });
        it("Check total pool size", async ()=> {
            let poolSize = await stakingInstance.getTotalPool()
            assert.strictEqual(poolSize.toNumber(), 1E4 * 4)
        })
        it("Check stakedBalance", async ()=> {
            let balance = await stakingInstance.getStakedBalance(accounts[0])
            assert.strictEqual(balance.toNumber(), 1E4)
        })
        it("Check if balance sufficient", async () => {
            await truffleAssert.reverts(stakingInstance.stakeTokens(10, {from:accounts[4]}), "Insufficient $MYST")
        })
    });

    describe("Claim Rewards", async ()=> {
        it("Claim rewards", async () => {
            await stakingInstance.minusOneYearFromRewardCalc(accounts[0])
            let claim = await stakingInstance.claimRewards({from:accounts[0]});
            truffleAssert.eventEmitted(claim, "RewardsClaimed")
        })
        it("Claim without staking fails", async () => {
            await truffleAssert.reverts(stakingInstance.claimRewards({from:accounts[4]}), "You do not have any tokens staked!")
        })
    })

    describe("Unstaking", async () => {
        it("Unstake All Tokens", async () => {
            let balanceAcc0 = (await stakingInstance.getStakedBalance(accounts[0])).toNumber()
            let unstake1 = await stakingInstance.unstakeTokens(balanceAcc0, {from:accounts[0]})
            truffleAssert.eventEmitted(unstake1, "TokenUnstaked")
        })
        it ("Check if staking balance is correct after unstake all", async () => {
            let stakedBalance = await stakingInstance.getStakedBalance(accounts[0])
            assert.strictEqual(stakedBalance.toNumber(), 0)
        })
        it("Unstake without a stake", async () => {
            await truffleAssert.reverts(stakingInstance.unstakeTokens(10, {from: accounts[0]}), "You do not have any tokens staked!")
        })
        it("Unstake amt greater than stake", async () => {
            await truffleAssert.reverts(stakingInstance.unstakeTokens(1E5, {from: accounts[1]}), "Amount to unstake exceeds staking balance!")
        })
    })

})