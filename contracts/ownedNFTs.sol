// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract ownedNFTs {
    uint256 private numNFTs;
    uint256 private nextAvailableSlot;
    
    struct nft {
        address parentContract;
        uint256 price;
        uint256 tokenId;
    }

    mapping(uint256 => nft) private unwantedNFTs;    
    mapping(uint256 => nft) private soldNFTs;

    event nftAdded(uint256 price, address nftAddress, uint256 tokenId);
    event nftSold(uint256 price, address nftAddress, uint256 tokenId);

    function add(uint256 price, address nftAddress, uint256 tokenId) public {
        unwantedNFTs[nextAvailableSlot] = nft(nftAddress, price, tokenId);
        numNFTs += 1;
        nextAvailableSlot += 1;
        emit nftAdded(price, nftAddress, tokenId);
    }

    function remove(uint256 id) public returns (address parentContract, uint256 price, uint256 tokenId) {
        require(id < nextAvailableSlot, "Invalid Id inserted");
        require(soldNFTs[id].parentContract != address(0), "NFT has already been transferred");
        address nftAdd = soldNFTs[id].parentContract;
        uint256 nftprice = soldNFTs[id].price;
        uint256 nfttokenId = soldNFTs[id].tokenId;

        soldNFTs[id].parentContract = address(0);

        return (nftAdd, nftprice, nfttokenId);
    }

    function sold(uint256 id) public {
        require(id < nextAvailableSlot, "Invalid Id inserted");
        require(unwantedNFTs[id].parentContract != address(0), "NFT has already been sold");
        soldNFTs[id] = unwantedNFTs[id];
        unwantedNFTs[id].parentContract = address(0);
        emit nftSold(soldNFTs[id].price, soldNFTs[id].parentContract, soldNFTs[id].tokenId);
    }

    function getParentContract(uint256 id) public view returns(address) {
        return unwantedNFTs[id].parentContract;
    }

    function getPrice(uint256 id) public view returns(uint256) {
        return unwantedNFTs[id].price;
    }

    function getTokenId(uint256 id) public view returns(uint256) {
        return unwantedNFTs[id].tokenId;
    }

    function getMaximumSize() public view returns(uint256) {
        return nextAvailableSlot == 0 ? 0 : nextAvailableSlot-1;
    }

}