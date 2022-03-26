// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OwnedNFTs {
    struct nft {
        address parentContract;
        uint256 price;
        uint256 tokenId;
        bool isValued;
    }

    mapping(uint256 => nft) private unwantedNFTs;
    mapping(uint256 => nft) private soldNFTs;
    uint256 private nextAvailableSlot;
    uint256 private unwantedSize;

    mapping(uint256 => nft) private valuedNFTs;
    mapping(uint256 => nft) private soldValuedNFTs;
    uint256 private nextSlot;
    uint256 private valuedSize;

    event nftAdded(uint256 price, address nftAddress, uint256 tokenId);
    event nftSold(uint256 price, address nftAddress, uint256 tokenId);
    event nftTransfered(uint256 price, address nftAddress, uint256 tokenId);

    function add(
        uint256 price,
        address nftAddress,
        uint256 tokenId,
        bool isValued
    ) public {
        if (isValued) {
            valuedNFTs[nextSlot] = nft(nftAddress, price, tokenId, isValued);
            nextSlot += 1;
            valuedSize += 1;
        } else {
            unwantedNFTs[nextAvailableSlot] = nft(
                nftAddress,
                price,
                tokenId,
                isValued
            );
            nextAvailableSlot += 1;
            unwantedSize += 1;
        }
        emit nftAdded(price, nftAddress, tokenId);
    }

    function remove(uint256 id, bool isValued)
        public
        returns (
            address parentContract,
            uint256 price,
            uint256 tokenId,
            bool value
        )
    {
        if (isValued) {
            require(id < nextSlot, "Invalid Id inserted");
            require(
                valuedNFTs[id].parentContract == address(0),
                "NFT has not been sold"
            );
            require(
                soldValuedNFTs[id].parentContract != address(0),
                "NFT has already been transferred"
            );
            address NFTAdd = soldValuedNFTs[id].parentContract;
            uint256 NFTprice = soldValuedNFTs[id].price;
            uint256 NFTtokenId = soldValuedNFTs[id].tokenId;
            soldValuedNFTs[id].parentContract = address(0);
            emit nftTransfered(NFTprice, NFTAdd, NFTtokenId);
            return (NFTAdd, NFTprice, NFTtokenId, isValued);
        }
        require(id < nextAvailableSlot, "Invalid Id inserted");
        require(
            unwantedNFTs[id].parentContract == address(0),
            "NFT has not been sold"
        );
        require(
            soldNFTs[id].parentContract != address(0),
            "NFT has already been transferred"
        );
        address nftAdd = soldNFTs[id].parentContract;
        uint256 nftprice = soldNFTs[id].price;
        uint256 nfttokenId = soldNFTs[id].tokenId;
        soldNFTs[id].parentContract = address(0);
        emit nftTransfered(nftprice, nftAdd, nfttokenId);
        return (nftAdd, nftprice, nfttokenId, isValued);
    }

    function sold(uint256 id, bool isvalued) public {
        if (isvalued) {
            require(id < nextSlot, "Invalid Id inserted");
            require(
                valuedNFTs[id].parentContract != address(0),
                "NFT has already been sold"
            );
            soldValuedNFTs[id] = valuedNFTs[id];
            valuedNFTs[id].parentContract = address(0);
            valuedSize -= 1;
            emit nftSold(
                soldValuedNFTs[id].price,
                soldValuedNFTs[id].parentContract,
                soldValuedNFTs[id].tokenId
            );
        } else {
            require(id < nextAvailableSlot, "Invalid Id inserted");
            require(
                unwantedNFTs[id].parentContract != address(0),
                "NFT has already been sold"
            );
            soldNFTs[id] = unwantedNFTs[id];
            unwantedNFTs[id].parentContract = address(0);
            unwantedSize -= 1;
            emit nftSold(
                soldNFTs[id].price,
                soldNFTs[id].parentContract,
                soldNFTs[id].tokenId
            );
        }
    }

    function getParentContract(uint256 id, bool isValued)
        public
        view
        returns (address)
    {
        return
            isValued
                ? valuedNFTs[id].parentContract
                : unwantedNFTs[id].parentContract;
    }

    function getPrice(uint256 id, bool isValued) public view returns (uint256) {
        return isValued ? valuedNFTs[id].price : unwantedNFTs[id].price;
    }

    function getTokenId(uint256 id, bool isValued)
        public
        view
        returns (uint256)
    {
        return isValued ? valuedNFTs[id].tokenId : unwantedNFTs[id].tokenId;
    }

    function getSize(bool isValued) public view returns (uint256) {
        return isValued ? valuedSize : unwantedSize;
    }

    function indexUpperBound(bool isValued) public view returns (uint256) {
        return
            isValued
                ? nextSlot
                : nextAvailableSlot;
    }
}
