pragma solidity ^0.5.0;
import "./ownedNFTs.sol";

contract MysteryBox {
    ownedNFTs ownedNFTInstance;
    enum tierPrices {
        Basic,
        Premium,
        Mysterious
    }
    struct Box {
        uint id;
        address purchaser;
        mapping(uint => address) nfts;
        uint tier;
    }
    mapping(uint => address) boxOwners;
    uint256 nextBoxId;

    constructor(ownedNFTs ownedNFTs) public {
        ownedNFTInstance = ownedNFTs;
    }

    event boxMade(tierPrices tier);
    event transferMade(address purchaser);
    event boxOpen(address purchaser);
    
    function makeBox(tierPrices tier) public {
        // fill up the box with nfts though rng
        // add box.id to boxOwners
    }

    function transfer(tierPrices tier, address purchaser) public payable{
        // Do require checks on msg.value
    }

    function rngNFT() public returns (uint16) {
        // function to generate a certain index 
    }

    function openBox() {
        // remove from mapping
        // returns all NFTs in the box
    }
}