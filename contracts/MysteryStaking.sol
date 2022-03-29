pragma solidity >= 0.5.0;

import './ERC20.sol';

contract MysteryStaking {
    ERC20 mystToken;
    address owner;

    uint256 totalPool; //total amount of PTs in the pool
    uint256 poolAPY; // percentage APY of the pool
    address[] stakers; //List of addresses that staked
    mapping(address => uint256) stakingBalance; // How much each address staked
    mapping(address => uint256) lastRewardCalcTime; // Start of staking for the address in unix timestamp
    mapping(address => uint256) rewardsEarned; // How much they earn in rewards
    mapping(address => bool) isStaking; 

    constructor() public {
        mystToken = new ERC20();
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

    function getMYST() public payable returns(uint256) { 
        require(msg.value >= 1E16, "At least 0.01ETH needed to get MYST");
        uint256 val = msg.value/ 1E16;
        mystToken.mint(msg.sender, val);
        emit GetMYST(msg.sender, val);
    }

    function transferMYST(address to, uint256 amount) private { 
        mystToken.transfer(to, amount);
        emit Transfer(to, amount);
    }

    function stakeTokens(uint256 amt) public { //send MYST to the pool
        if(isStaking[msg.sender]) {
            calculateRewards(msg.sender);
        }
        mystToken.transferFrom(msg.sender, address(this), amt);
        stakingBalance[msg.sender] += amt;
        lastRewardCalcTime[msg.sender] = block.timestamp / 1000;
        isStaking[msg.sender] = true;
        totalPool += amt;
        emit TokenStaked(msg.sender, amt);
    }

    function unstakeTokens(uint256 amt) public {
        require(isStaking[msg.sender], "You do not have any tokens staked!");
        require(stakingBalance[msg.sender] >= amt, "Amount to unstake exceeds staking balance!");
        unstakeClaimRewards(msg.sender);
        transferMYST(msg.sender, amt);
        totalPool -= amt;
        if (stakingBalance[msg.sender] == amt) {
            isStaking[msg.sender] = false;
            stakingBalance[msg.sender] = 0;
        }
        else {
            stakingBalance[msg.sender] -= amt;
        }
        emit TokenUnstaked(msg.sender, amt);
    }

    function claimRewards() public {
        require(isStaking[msg.sender], "You do not have any tokens staked!");
        require(rewardsEarned[msg.sender] > 0, "You do not have any rewards!");
        calculateRewards(msg.sender);
        uint256 memory amt = rewardsEarned[msg.sender];
        transferMYST(msg.sender, amt);
        rewardsEarned[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, amt);
    }

    function unstakeClaimRewards(address sender) private {
        require(rewardsEarned[msg.sender] > 0, "You do not have any rewards!");
        calculateRewards(msg.sender);
        uint256 memory amt = rewardsEarned[msg.sender];
        transferMYST(msg.sender, amt);
        rewardsEarned[msg.sender] = 0;
    }

    function calculateRewards(address sender) private {
        rewardsEarned[sender] += (now/1000 - lastRewardCalcTime[msg.sender]) * stakingBalance[msg.sender] * (poolAPY / 100 / 365 / 24 / 60);
        lastRewardCalcTime[sender] = now/1000;
        //checks for NFT and add more APY here.
    }

//getter functions for testing
    function getTotalPool() public view returns(uint256) {
        return totalPool;
    }

    function getTokenBalance(address user) public view returns(uint256) {
        return mystToken.balanceOf(user);
    }

    function getStakedBalance(address user) public view returns(uint256) {
        return stakingBalance[user];
    }

    function getRewardsEarned(address user) public view returns (uint256) {
        calculateRewards(user);
        return rewardsEarned[user];
    }

}