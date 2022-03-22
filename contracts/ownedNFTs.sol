pragma solidity >=0.5.0;

contract ownedNFTs {
    uint256 private numNFTs;
    uint256 private nextAvailableSlot;
    mapping(uint256 => address) private unwantedNFTs;
    mapping(uint256 => uint256) private NFTPrices;
    
    mapping(uint256 => address) private soldNFTs;
    mapping(uint256 => uint256) private soldNFTPrices;

    function add(uint256 price, address nftAddress) public {
        unwantedNFTs[nextAvailableSlot] = nftAddress;
        NFTPrices[nextAvailableSlot] = price;
        numNFTs += 1;
        nextAvailableSlot += 1;
    }

    function remove(uint256 id) public returns (uint256, address) {
        require(soldNFTs[id] != address(0), "NFT has already been transferred");
        require(soldNFTPrices[id] != 0, "NFT has already been transferred");
        address nftAdd = soldNFTs[id];
        uint256 price = soldNFTPrices[id];

        soldNFTs[id] = address(0);
        soldNFTPrices[id] = 0;

        return (price, nftAdd);
    }

    function sold(uint256 id) public {
        require(unwantedNFTs[id] != address(0), "NFT has already been sold");
        require(NFTPrices[id] != 0, "NFT has already been sold");

        address nftAdd = unwantedNFTs[id];
        uint256 price = NFTPrices[id];

        soldNFTs[id] = nftAdd;
        soldNFTPrices[id] = price;
        unwantedNFTs[id] = address(0);
        NFTPrices[id] = 0;
    }

}