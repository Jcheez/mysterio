pragma solidity ^0.5.0;

contract ownedNFTs {
    uint256 private numNFTs;
    uint256 private nextAvailableSlot;
    mapping(uint256 => address) private unwantedNFTs;
    mapping(uint256 => uint256) private NFTPrices;

    function add(uint256 price, address nftAddress) public {
        unwantedNFTs[nextAvailableSlot] = nftAddress;
        NFTPrices[nextAvailableSlot] = price;
        numNFTs += 1;
        nextAvailableSlot += 1;
    }

    function remove(uint256 id) public returns (uint256, address) {
        require(unwantedNFTs[id] != address(0), "NFT has already been removed");
        require(NFTPrices[id] != 0, "NFT has already been removed");
        address nftAdd = unwantedNFTs[id];
        uint256 price = NFTPrices[id];

        unwantedNFTs[id] = address(0);
        NFTPrices[id] = 0;

        return (price, nftAdd);
    }

}