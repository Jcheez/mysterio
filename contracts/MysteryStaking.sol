pragma solidity >=0.5.0;

import "./ERC20.sol";
import "./MysteryNFT.sol";

contract MysteryStaking {
    ERC20 mystToken;
    MysteryNFT mysteryNFT;
    address owner;

    uint256 totalPool; //total amount of PTs in the pool
    uint256 poolAPY; // percentage APY of the pool
    address[] stakers; //List of addresses that staked
    mapping(address => uint256) stakingBalance; // How much each address staked
    mapping(address => uint256) lastRewardCalcTime; // Start of staking for the address in unix timestamp
    mapping(address => uint256) rewardsEarned; // How much they earn in rewards
    mapping(address => bool) isStaking;

    constructor(MysteryNFT mysteryNFTcontract) {
        mystToken = new ERC20();
        mysteryNFT = mysteryNFTcontract;
        owner = msg.sender;
        totalPool = 0;
        poolAPY = 60; // 60% a year
    }

    event Transfer(address to, uint256 amount);
    event TokenSent(address sender, uint256 amt);
    event GetMYST(address sender, uint256 amt);
    event TokenStaked(address sender, uint256 amt);
    event RewardsClaimed(address sender, uint256 amt);
    event TokenUnstaked(address sender, uint256 amt);

    //for testing purposes
    function getMYST() public payable returns (uint256) {
        require(msg.value >= 1E16, "At least 0.01ETH needed to get MYST");
        uint256 val = msg.value / 1E4;
        mystToken.mint(msg.sender, val);
        emit GetMYST(msg.sender, val);
    }

    function transferMYST(address to, uint256 amount) private {
        mystToken.transfer(to, amount);
        emit Transfer(to, amount);
    }

    function stakeTokens(uint256 amt) public {
        //send MYST to the pool
        require(mystToken.balanceOf(msg.sender) >= amt, "Insufficient $MYST");
        if (isStaking[msg.sender]) {
            rewardsEarned[msg.sender] += calculateRewards(msg.sender);
            lastRewardCalcTime[msg.sender] = block.timestamp;
            mystToken.transferFrom(msg.sender, address(this), amt);
            stakingBalance[msg.sender] += amt;
            isStaking[msg.sender] = true;
            totalPool += amt;
            emit TokenStaked(msg.sender, amt);
        } else {
            mystToken.transferFrom(msg.sender, address(this), amt);
            stakers.push(msg.sender);
            rewardsEarned[msg.sender] = 0;
            lastRewardCalcTime[msg.sender] = block.timestamp;
            stakingBalance[msg.sender] = amt;
            isStaking[msg.sender] = true;
            totalPool += amt;
            emit TokenStaked(msg.sender, amt);
        }
    }

    function unstakeTokens(uint256 amt) public {
        require(
            isStaking[msg.sender] == true,
            "You do not have any tokens staked!"
        );
        require(
            stakingBalance[msg.sender] >= amt,
            "Amount to unstake exceeds staking balance!"
        );
        unstakeClaimRewards(msg.sender);
        transferMYST(msg.sender, amt);
        totalPool -= amt;
        if (stakingBalance[msg.sender] == amt) {
            isStaking[msg.sender] = false;
            stakingBalance[msg.sender] = 0;
        } else {
            stakingBalance[msg.sender] -= amt;
        }
        emit TokenUnstaked(msg.sender, amt);
    }

    function claimRewards() public {
        require(
            isStaking[msg.sender] == true,
            "You do not have any tokens staked!"
        );
        rewardsEarned[msg.sender] += calculateRewards(msg.sender);
        lastRewardCalcTime[msg.sender] = block.timestamp;
        uint256 amt = rewardsEarned[msg.sender];
        transferMYST(msg.sender, amt);
        rewardsEarned[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, amt);
    }

    function unstakeClaimRewards(address sender) private {
        rewardsEarned[sender] += calculateRewards(sender);
        lastRewardCalcTime[sender] = block.timestamp;
        transferMYST(sender, rewardsEarned[sender]);
        rewardsEarned[sender] = 0;
    }

    function calculateRewards(address sender) internal view returns (uint256) {
        if (mysteryNFT.balanceOf(sender) > 0) {
            uint256 rate = calculateBoostedAPY(sender);
            return ((((block.timestamp - lastRewardCalcTime[sender]) *
                    stakingBalance[sender]) / (365 * 24 * 60 * 60)) * rate) /
                100;
        } else {
            return
                ((((block.timestamp - lastRewardCalcTime[sender]) *
                    stakingBalance[sender]) / (365 * 24 * 60 * 60)) * poolAPY) /
                100;
        }
    }

    //getter functions for testing
    function getTotalPool() public view returns (uint256) {
        return totalPool;
    }

    function getTokenBalance(address user) public view returns (uint256) {
        return mystToken.balanceOf(user);
    }

    function getStakedBalance(address user) public view returns (uint256) {
        return stakingBalance[user];
    }

    function getRewardsEarned(address user) public view returns (uint256) {
        return rewardsEarned[user];
    }

    function getERCInstance() public view returns (ERC20) {
        return mystToken;
    }

    function calculateBoostedAPY(address user) internal view returns (uint256) {
        uint256 numNFTs = mysteryNFT.balanceOf(user);
        uint256 rate = poolAPY;
        for (uint256 i = 0; i < numNFTs; i++) {
            uint256 tokenId = mysteryNFT.tokenOfOwnerByIndex(user, i);
            uint8 rarity = mysteryNFT.getRarity(tokenId);
            if (rarity == 0) {
                rate += 5;
            }
            if (rarity == 1) {
                rate += 10;
            }
            if (rarity == 2) {
                rate += 20;
            }
        }
        return rate;
    }

    //testing only
    function minusOneYearFromRewardCalc(address user) public {
        lastRewardCalcTime[user] -= 365 * 24 * 60 * 60;
        //lastRewardCalcTime[user] = 1633508809;
    }
}
