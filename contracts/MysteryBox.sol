// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ownedNFTs.sol";
import "./MysteryStaking.sol";
import "./MysteryNFT.sol";

contract MysteryBox {
    OwnedNFTs ownedNFTInstance;
    MysteryStaking mysterystakingInstance;
    MysteryNFT mysteryNFTInstance;

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

    mapping(address => Box[]) ownedBoxes;
    mapping(uint256 => Box) boxList;
    uint256 nextBoxId;

    constructor(
        OwnedNFTs ownedNFT,
        MysteryStaking mysterystaking,
        MysteryNFT mysteryNFT
    ) {
        ownedNFTInstance = ownedNFT;
        mysterystakingInstance = mysterystaking;
        mysteryNFTInstance = mysteryNFT;
    }

    event boxMade(uint256 boxId, uint8 tier);
    event transferMade(address purchaser);
    event boxOpen(address purchaser);

    function makeBox(uint8 tier, address purchaser) private returns (uint256) {
        nextBoxId++;
        uint16 boxNFTid = 0;
        uint256 minVal = 0;
        uint256 rareInt = rngRarity();

        uint8 rareNFT = 0;
        uint128 boxMinPrice;
        if (tier == 0) {
            boxMinPrice = 0.03 ether;
            if (rareInt >= 95) {
                rareNFT = 1;
            }
        } else if (tier == 1) {
            boxMinPrice = 0.065 ether;
            if (rareInt >= 70) {
                rareNFT = 1;
            }
        } else {
            boxMinPrice = 0.1 ether;
            if (rareInt >= 40) {
                rareNFT = 1;
            }
        }

        // fill up the box with nfts though rng
        while (minVal < boxMinPrice) {
            if (rareNFT == 1) {
                // rare NFT draw
                if (ownedNFTInstance.getSize(true) == 0) {
                    rareNFT--;
                    continue; // no more rare to draw, skip to normal NFTs
                }
                uint256 rngNumR = rngNFT(
                    ownedNFTInstance.indexUpperBound(true)
                );
                while (
                    ownedNFTInstance.getParentContract(rngNumR, true) ==
                    address(0)
                ) {
                    uint256 sizeValued = ownedNFTInstance.indexUpperBound(
                        true
                    ) == 0
                        ? 1
                        : ownedNFTInstance.indexUpperBound(true);
                    rngNumR = (rngNumR + 1) % sizeValued;
                }
                uint256 priceOfNFTDrawnR = ownedNFTInstance.getPrice(
                    rngNumR,
                    true
                );
                boxNFTid++;
                // update minval
                minVal += priceOfNFTDrawnR;
                ownedNFTInstance.sold(rngNumR, true);
                rareNFT--;
                boxList[nextBoxId].nfts.push(
                    nft(
                        ownedNFTInstance.getParentContract(rngNumR, true),
                        ownedNFTInstance.getPrice(rngNumR, true),
                        ownedNFTInstance.getTokenId(rngNumR, true),
                        true
                    )
                );
                boxList[nextBoxId].nftIds.push(rngNumR);
            }
            if (ownedNFTInstance.getSize(false) == 0) {
                break; // no more NFTs to fill, break infinite loop
            }
            // filling up the box with other NFTs
            uint256 rngNum = rngNFT(ownedNFTInstance.indexUpperBound(false));
            while (
                ownedNFTInstance.getParentContract(rngNum, false) == address(0)
            ) {
                uint256 size = ownedNFTInstance.indexUpperBound(false) == 0
                    ? 1
                    : ownedNFTInstance.indexUpperBound(false);
                rngNum = (rngNum + 1) % size;
            }
            uint256 priceOfNFTDrawn = ownedNFTInstance.getPrice(rngNum, false);
            boxNFTid++;

            // update minval
            minVal += priceOfNFTDrawn;
            ownedNFTInstance.sold(rngNum, false);
            boxList[nextBoxId].nfts.push(
                nft(
                    ownedNFTInstance.getParentContract(rngNum, false),
                    ownedNFTInstance.getPrice(rngNum, false),
                    ownedNFTInstance.getTokenId(rngNum, false),
                    false
                )
            );
            boxList[nextBoxId].nftIds.push(rngNum);
        }

        // add box to boxList
        boxList[nextBoxId].id = nextBoxId;
        boxList[nextBoxId].purchaser = purchaser;
        boxList[nextBoxId].tier = tier;
        boxList[nextBoxId].isOpen = false;

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
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else if (tier == 1) {
            require(
                msg.value >= 0.10 ether,
                "0.1 ether is needed to make the premium box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else {
            require(
                msg.value >= 0.15 ether,
                "0.15 ether is needed to make the mysterious box"
            );
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        }
    }

    function transferMYST(uint8 tier, address purchaser) public {
        // Do require checks on msg.value
        if (tier == 0) {
            require(
                mysterystakingInstance.getERCInstance().balanceOf(msg.sender) >=
                    5,
                "5 MYST is needed to make the basic box"
            );
            mysterystakingInstance.getERCInstance().deduct(msg.sender, 5);
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else if (tier == 1) {
            require(
                mysterystakingInstance.getERCInstance().balanceOf(msg.sender) >=
                    10,
                "10 MYST is needed to make the premium box"
            );
            mysterystakingInstance.getERCInstance().deduct(msg.sender, 10);
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        } else {
            require(
                mysterystakingInstance.getERCInstance().balanceOf(msg.sender) >=
                    15,
                "15 MYST is needed to make the mysterious box"
            );
            mysterystakingInstance.getERCInstance().deduct(msg.sender, 15);
            uint256 newBoxId = makeBox(tier, purchaser);
            Box[] storage listOfBoxes = ownedBoxes[msg.sender];
            listOfBoxes.push(boxList[newBoxId]);
            ownedBoxes[msg.sender] = listOfBoxes;
            emit transferMade(purchaser);
        }
    }

    function openBox(uint256 boxID) public returns (ERC721[] memory) {
        require(
            boxList[boxID].purchaser == msg.sender,
            "this box does not belong to you"
        );
        require(boxList[boxID].isOpen == false, "box has already been opened");
        // transfers all NFTs in the box
        Box memory yourBox = boxList[boxID];
        ERC721[] memory nftAddresses;
        address[] memory mystNFTminting;
        for (uint256 i = 0; i < yourBox.nfts.length; i++) {
            if (yourBox.nfts[i].parentContract == address(0)) {
                break;
            }
            ERC721(yourBox.nfts[i].parentContract).setApprovalForAll(
                msg.sender,
                true
            );
            ERC721(yourBox.nfts[i].parentContract).transferFrom(
                address(this),
                msg.sender,
                yourBox.nfts[i].tokenId
            );
            mystNFTminting[i] = yourBox.nfts[i].parentContract;
            nftAddresses[i] = ERC721(yourBox.nfts[i].parentContract);
            ownedNFTInstance.remove(
                yourBox.nftIds[i],
                yourBox.nfts[i].isValued
            );
        }
        mysteryNFTInstance.mint(boxList[boxID].tier, mystNFTminting);
        boxList[boxID].isOpen = true;
        emit boxOpen(msg.sender);
        return nftAddresses;
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
        return ownedNFTInstance.indexUpperBound(false);
    }
}
