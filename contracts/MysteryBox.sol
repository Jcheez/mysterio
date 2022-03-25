// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./OwnedNFTs.sol";

contract MysteryBox {
    OwnedNFTs ownedNFTInstance;
    enum tierPrices {
        basic,
        premium,
        mysterious
    }

    struct Box {
        uint256 id;
        address purchaser;
        nft[] nfts;
        tierPrices tier;
        bool isOpen;
        uint256[] nftIds;
    }

    struct nft {
        address parentContract;
        uint256 price;
        uint256 tokenId;
    }
    nft[] boxNFTList;
    uint256[] BoxnftIds;
    
    mapping(address => Box[]) ownedBoxes;
    mapping(uint256 => Box) boxList;
    uint256 nextBoxId;
    

    constructor(OwnedNFTs ownedNFT) {
        ownedNFTInstance = ownedNFT;
    }

    event boxMade(uint256 boxId, tierPrices tier);
    event transferMade(address purchaser);
    event boxOpen(address purchaser);

    function makeBox(tierPrices tier, address purchaser) private returns (uint256) {
        nextBoxId++;
        uint16 boxNFTid = 0;
        uint256 minVal = 0;

        uint128 boxMinPrice;
        uint128 boxMaxPrice;
        if ((keccak256(abi.encodePacked((tier))) == keccak256(abi.encodePacked(("basic"))))) {
            boxMinPrice = 0.30 ether;
            boxMaxPrice = 0.35 ether;
        } else if ((keccak256(abi.encodePacked((tier))) == keccak256(abi.encodePacked(("premium"))))) {
            boxMinPrice = 0.65 ether;
            boxMaxPrice = 0.80 ether;
        } else {
            boxMinPrice = 1 ether;
            boxMaxPrice = 1.25 ether;
        }

        // fill up the box with nfts though rng
        while (minVal < boxMinPrice) {
            uint rngNum = rngNFT(ownedNFTInstance.getMaximumSize());
            uint256 priceOfNFTDrawn = ownedNFTInstance.getPrice(rngNum);
            if (priceOfNFTDrawn + minVal > boxMaxPrice) {
                continue;
                // do not add NFT that cause total to exceed max price
                // draw another number for NFT
            } else {
                // assign NFT to boxNFTList
                boxNFTid++;
                
                boxNFTList[boxNFTid] = nft(
                    ownedNFTInstance.getParentContract(rngNum),
                    ownedNFTInstance.getPrice(rngNum),
                    ownedNFTInstance.getTokenId(rngNum)
                );
                // update minval
                minVal += priceOfNFTDrawn;
                ownedNFTInstance.sold(rngNum);
                BoxnftIds[boxNFTid] = rngNum;
            }
        }

        // add box to boxList
        boxList[nextBoxId].id = nextBoxId;
        boxList[nextBoxId].purchaser = purchaser;
        boxList[nextBoxId].nfts = boxNFTList;
        boxList[nextBoxId].tier = tier;
        boxList[nextBoxId].isOpen = false;
        boxList[nextBoxId].nftIds= BoxnftIds;

        delete boxNFTList;
        delete BoxnftIds;
        emit boxMade(nextBoxId, tier);
        return nextBoxId;
    }

    function transfer(tierPrices tier, address purchaser) public payable {
        // Do require checks on msg.value
        if ((keccak256(abi.encodePacked((tier))) == keccak256(abi.encodePacked(("basic"))))) {
            require(
                msg.value >= 0.5 ether,
                "0.5 ether is needed to make the basic box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = boxList[newBoxId];
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else if ((keccak256(abi.encodePacked((tier))) == keccak256(abi.encodePacked(("Premium"))))) {
            require(
                msg.value >= 1 ether,
                "1 ether is needed to make the premium box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = boxList[newBoxId];
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else {
            require(
                msg.value >= 1.5 ether,
                "1.5 ether is needed to make the mysterious box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = boxList[newBoxId];
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        }
    }

    function openBox(uint256 boxID) public returns (ERC721[] memory) {
        require(
            boxList[boxID].purchaser == msg.sender,
            "this box does not belong to you"
        );
        // transfers all NFTs in the box
        Box memory yourBox = boxList[boxID];
        require(yourBox.isOpen == false, "box has already been opened");
        ERC721[] memory nfts;
        for (uint256 i = 0; i < yourBox.nfts.length; i++) {
            // need to check if there needs to be owner for this contract
            // check how to get nft id for transferring
            ERC721(yourBox.nfts[i].parentContract).transferFrom(address(this), msg.sender, yourBox.nfts[i].tokenId);
            nfts[i] = ERC721(yourBox.nfts[i].parentContract);
            ownedNFTInstance.remove(yourBox.nftIds[i]);
        }
        yourBox.isOpen = true;
        return nfts;
    }

    function checkBoxesIds() public view returns (Box[] memory) {
        require(ownedBoxes[msg.sender].length > 0, "you do not own any boxes");
        return ownedBoxes[msg.sender];
    }

    function rngNFT(uint size) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % size;
    }
}
