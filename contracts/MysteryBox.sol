// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ownedNFTs.sol";

contract MysteryBox {
    OwnedNFTs ownedNFTInstance;
    //enum tierPrices {
    //    basic,
    //    premium,
    //    mysterious
    //}

    struct Box {
        uint256 id;
        address purchaser;
        nft[] nfts;
        uint8 tier;
        bool isOpen;
        uint256[] nftIds;
    }

    struct nft {
        address parentContract;
        uint256 price;
        uint256 tokenId;
        bool isValued;
    }
    nft[] boxNFTList;
    uint256[] BoxnftIds;

    mapping(address => Box[]) ownedBoxes;
    mapping(uint256 => Box) boxList;
    uint256 nextBoxId;

    constructor(OwnedNFTs ownedNFT) {
        ownedNFTInstance = ownedNFT;
    }

    event boxMade(uint256 boxId, uint8 tier);
    event transferMade(address purchaser);
    event boxOpen(address purchaser);

    function makeBox(uint8 tier, address purchaser)
        public
        payable
        returns (uint256)
    {
        nextBoxId++;
        uint16 boxNFTid = 0;
        uint256 minVal = 0;
        uint256 rareInt = rngRarity();

        uint8 rareNFT = 0;
        uint128 boxMinPrice;
        //uint128 boxMaxPrice;
        if (tier == 0) {
            boxMinPrice = 0.03 ether;
            //boxMaxPrice = 0.035 ether;
            if (rareInt >= 95) {
                rareNFT = 1;
            }
        } else if (tier == 1) {
            boxMinPrice = 0.065 ether;
            //boxMaxPrice = 0.080 ether;
            if (rareInt >= 70) {
                rareNFT = 1;
            }
        } else {
            boxMinPrice = 0.1 ether;
            //boxMaxPrice = 0.125 ether;
            if (rareInt >= 40) {
                rareNFT = 1;
            }
        }

        // fill up the box with nfts though rng
        while (minVal < boxMinPrice) {
            if (rareNFT == 1) {
                // rare NFT draw, which might exceed max value
                uint256 rngNumR = rngNFT(ownedNFTInstance.getSize(true));
                while (
                    ownedNFTInstance.getParentContract(rngNumR, true) ==
                    address(0)
                ) {
                    uint256 sizeValued = ownedNFTInstance.getSize(true) == 0
                        ? 1
                        : ownedNFTInstance.getSize(true);
                    rngNumR = (rngNumR + 1) % sizeValued;
                }
                uint256 priceOfNFTDrawnR = ownedNFTInstance.getPrice(
                    rngNumR,
                    true
                );
                boxNFTid++;

                boxNFTList.push(
                    nft(
                        ownedNFTInstance.getParentContract(rngNumR, true),
                        ownedNFTInstance.getPrice(rngNumR, true),
                        ownedNFTInstance.getTokenId(rngNumR, true),
                        true
                    )
                );
                // update minval
                minVal += priceOfNFTDrawnR;
                ownedNFTInstance.sold(rngNumR, true);
                BoxnftIds.push(rngNumR);
                rareNFT--;
            }

            // filling up the box with other NFTs
            uint256 rngNum = rngNFT(ownedNFTInstance.getSize(false));
            while (
                ownedNFTInstance.getParentContract(rngNum, false) == address(0)
            ) {
                uint256 size = ownedNFTInstance.getSize(false) == 0
                    ? 1
                    : ownedNFTInstance.getSize(false);
                rngNum = (rngNum + 1) % size;
            }
            uint256 priceOfNFTDrawn = ownedNFTInstance.getPrice(rngNum, false);
            boxNFTid++;

            boxNFTList.push(
                nft(
                    ownedNFTInstance.getParentContract(rngNum, false),
                    ownedNFTInstance.getPrice(rngNum, false),
                    ownedNFTInstance.getTokenId(rngNum, false),
                    false
                )
            );
            // update minval
            minVal += priceOfNFTDrawn;
            ownedNFTInstance.sold(rngNum, false);
            BoxnftIds.push(rngNum);
        }

        // add box to boxList
        boxList[nextBoxId].id = nextBoxId;
        boxList[nextBoxId].purchaser = purchaser;
        boxList[nextBoxId].nfts = boxNFTList;
        boxList[nextBoxId].tier = tier;
        boxList[nextBoxId].isOpen = false;
        boxList[nextBoxId].nftIds = BoxnftIds;

        delete boxNFTList;
        delete BoxnftIds;
        emit boxMade(nextBoxId, tier);
        return nextBoxId;
    }

    function transfer(uint8 tier, address purchaser) public payable {
        // Do require checks on msg.value
        if (tier == 0) {
            require(
                msg.value >= 0.05 ether,
                "0.05 ether is needed to make the basic box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = boxList[newBoxId];
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else if (tier == 1) {
            require(
                msg.value >= 0.10 ether,
                "0.1 ether is needed to make the premium box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            uint256 length = listOfBoxes.length;
            listOfBoxes[length] = boxList[newBoxId];
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else {
            require(
                msg.value >= 0.15 ether,
                "0.15 ether is needed to make the mysterious box"
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
            ERC721(yourBox.nfts[i].parentContract).transferFrom(
                address(this),
                msg.sender,
                yourBox.nfts[i].tokenId
            );
            nfts[i] = ERC721(yourBox.nfts[i].parentContract);
            ownedNFTInstance.remove(
                yourBox.nftIds[i],
                yourBox.nfts[i].isValued
            );
        }
        yourBox.isOpen = true;
        return nfts;
    }

    function checkBoxesIds() public view returns (Box[] memory) {
        require(ownedBoxes[msg.sender].length > 0, "you do not own any boxes");
        return ownedBoxes[msg.sender];
    }

    function rngNFT(uint256 size) private view returns (uint256) {
        if (size == 0) {
            size = 1;
        }
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            size;
    }

    function rngRarity() private view returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            100;
    }

    function getOwnedInstance() public view returns (uint256) {
        return ownedNFTInstance.getSize(false);
    }
}
