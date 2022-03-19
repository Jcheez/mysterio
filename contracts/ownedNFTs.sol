pragma solidity ^0.5.0;

contract ownedNFTs {
    uint256 numNFTs;
    mapping(uint256 => address) private unwantedNFTs;
    mapping(uint256 => uint) private NFTPrices;

    function add(uint256 price, address add) public {
        // counter for next  
        // Find the next empty slot (address should be 0)
    }

    function delete(uint256 id) public returns (uint256, address) {
        // Change address of ID to 0
        // returns the address and price 
    }

}