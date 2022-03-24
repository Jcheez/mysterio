// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
import "./ownedNFTs.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MysteryBox {
    ownedNFTs ownedNFTInstance;
    enum tierPrices {
        basic,
        premium,
        mysterious
    }
    struct Box {
        uint256 id;
        address purchaser;
        ERC721Enumerable[] nfts;
        tierPrices tier;
        bool isOpen;
        uint256[] nftIds;
    }
    ERC721Enumerable[] boxNFTList;
    uint256[] BoxnftIds;
    
    mapping(address => Box[]) ownedBoxes;
    mapping(uint256 => Box) boxList;
    uint256 nextBoxId;
    

    constructor(ownedNFTs ownedNFT) {
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
            uint256 priceOfNFTDrawn = ownedNFTInstance.getPrices(rngNum);
            if (priceOfNFTDrawn + minVal > boxMaxPrice) {
                continue;
                // do not add NFT that cause total to exceed max price
                // draw another number for NFT
            } else {
                // assign NFT to boxNFTList
                boxNFTid++;
                boxNFTList[boxNFTid] = ownedNFTInstance.getUnwantedNFTs(rngNum);
                // update minval
                minVal += priceOfNFTDrawn;
                ownedNFTInstance.sold(rngNum);
                BoxnftIds[boxNFTid] = rngNum;
            }
        }

        // add box to boxList
        Box memory newBox = Box(nextBoxId, purchaser, boxNFTList, tier, false, BoxnftIds);
        boxList[nextBoxId] = newBox;
        emit boxMade(nextBoxId, tier);
        delete boxNFTList;
        delete BoxnftIds;
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
            Box memory newBox = boxList[newBoxId];
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = newBox;
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else if ((keccak256(abi.encodePacked((tier))) == keccak256(abi.encodePacked(("Premium"))))) {
            require(
                msg.value >= 1 ether,
                "1 ether is needed to make the premium box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box memory newBox = boxList[newBoxId];
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = newBox;
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else {
            require(
                msg.value >= 1.5 ether,
                "1.5 ether is needed to make the mysterious box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box memory newBox = boxList[newBoxId];
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = newBox;
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        }
    }

    function openBox(uint256 boxID, uint256 tokenId) public returns (ERC721Enumerable[] memory) {
        require(
            boxList[boxID].purchaser == msg.sender,
            "this box does not belong to you"
        );
        // transfers all NFTs in the box
        Box memory yourBox = boxList[boxID];
        require(yourBox.isOpen == false, "box has already been opened");
        ERC721Enumerable[] memory nfts;
        for (uint256 i = 0; i < yourBox.nfts.length; i++) {
            ERC721Enumerable nft = yourBox.nfts[i];
            // need to check if there needs to be owner for this contract
            // check how to get nft id for transferring
            nft.transferFrom(address(this), msg.sender, tokenId);
            nfts[i] = nft;
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
