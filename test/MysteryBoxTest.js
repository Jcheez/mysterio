const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");
const { cp } = require("fs");

const ownedNFTs = artifacts.require("./ownedNFTs.sol");
const MysteryBox = artifacts.require("./MysteryBox.sol");

contract("MysteryBox", (accounts) => {

    before(async () => {
        let ownedInstance = await ownedNFTs.deployed();
        let mBoxInstance = await MysteryBox.deployed();
    });
    
    // Unit test 1: Testing MakeBox (make sure event emitted)
        // Price is within range
    // Unit test 2: Testing transfer (make sure event emitted)
        // Insert 0.4 ether and make transfer fails
        // Make sure box is transferred to new owner
    // Unit test 3: Testing OpenBox (make sure event emitted)
        // Make sure other ppl cannot open what doesnt belong to them
        // Cannot open the same box twice
})