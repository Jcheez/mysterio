// pragma solidity >=0.5.0;
// import "./ownedNFTs.sol";

// contract MysteryBox {
//     ownedNFTs ownedNFTInstance;
//     enum tierPrices {
//         Basic,
//         Premium,
//         Mysterious
//     }
//     struct Box {
//         uint256 id;
//         address purchaser;
//         mapping(uint16 => address) nfts;
//         uint256 tier;
//         bool isOpen;
//     }
//     mapping(address => uint256[]) ownedBoxes;
//     mapping(uint256 => Box) boxList;
//     uint256 nextBoxId;

//     constructor(ownedNFTs ownedNFT) public {
//         ownedNFTInstance = ownedNFT;
//     }

//     event boxMade(uint256 boxId, tierPrices tier);
//     event transferMade(address purchaser);
//     event boxOpen(address purchaser);

//     function makeBox(tierPrices tier, address purchaser) private returns (Box memory) {
//         nextBoxId++;
//         mapping(uint16 => ERC721) boxNFTList;
//         uint16 boxNFTid = 0;
//         uint128 minVal = 0;

//         uint128 boxMinPrice;
//         uint128 boxMaxPrice;

//         if (tier == "Basic") {
//             boxMinPrice = 0.30 ether;
//             boxMaxPrice = 0.35 ether;
//         } else if (tier == "Premium") {
//             boxMinPrice = 0.65 ether;
//             boxMaxPrice = 0.80 ether;
//         } else {
//             boxMinPrice = 1 ether;
//             boxMaxPrice = 1.25 ether;
//         }

//         // fill up the box with nfts though rng
//         while (minVal < boxMinPrice) {
//             uint16 rngNum = rngNFT();
//             uint128 priceOfNFTDrawn = ownedNFTInstance.NFTPrices[rngNum];
//             if (priceOfNFTDrawn + minVal > boxMaxPrice) {
//                 continue;
//                 // do not add NFT that cause total to exceed max price
//                 // draw another number for NFT
//             } else {
//                 // assign NFT to boxNFTList
//                 boxNFTid++;
//                 boxNFTList[boxNFTid] = ownedNFTInstance.unwantedNFTs[rngNum];
//                 // update minval
//                 minVal += priceOfNFTDrawn;
//                 ownedNFTInstance.sold(rngNum);
//             }
//         }

//         // add box to boxList
//         Box memory newBox = Box(nextBoxId, purchaser, boxNFTList, tier, false);
//         boxList[nextBoxId] = newBox;
//         emit boxMade(nextBoxId, tier);
//         return newBox;
//     }

//     function transfer(tierPrices tier, address purchaser) public payable {
//         // Do require checks on msg.value
//         if (tier == "Basic") {
//             require(
//                 msg.value >= 0.5 ether,
//                 "0.5 ether is needed to make the basic box"
//             );
//             Box newBox = makeBox(tier, purchaser);
//             uint256[] listOfBoxes = ownedBoxes[msg.sender];
//             ownedBoxes[msg.sender] = listOfBoxes.push(newBox);
//             emit transferMade(purchaser);
//         } else if (tier == "Premium") {
//             require(
//                 msg.value >= 1 ether,
//                 "1 ether is needed to make the premium box"
//             );
//             Box newBox = makeBox(tier, purchaser);
//             uint256[] listOfBoxes = ownedBoxes[msg.sender];
//             ownedBoxes[msg.sender] = listOfBoxes.push(newBox);
//             emit transferMade(purchaser);
//         } else {
//             require(
//                 msg.value >= 1.5 ether,
//                 "1.5 ether is needed to make the mysterious box"
//             );
//             Box newBox = makeBox(tier, purchaser);
//             uint256[] listOfBoxes = ownedBoxes[msg.sender];
//             ownedBoxes[msg.sender] = listOfBoxes.push(newBox);
//             emit transferMade(purchaser);
//         }
//     }

//     function openBox(uint256 boxID) public returns (ERC721[]) {
//         require(
//             boxList[boxID].purchaser == msg.sender,
//             "this box does not belong to you"
//         );
//         // transfers all NFTs in the box
//         Box yourBox = boxList[boxID];
//         require(yourBox.isOpen == false, "box has already been opened");
//         ERC721[] nfts;
//         for (int256 i = 0; i < yourBox.nfts.length; i++) {
//             ERC721 nft = yourBox.nfts[i];
//             // need to check if there needs to be owner for this contract
//             // check how to get nft id for transferring
//             ercInstance.transferFrom(address(this), msg.sender, nft.id);
//             nfts.push(nft);
//             //ownedNFTInstance.remove();
//         }
//         yourBox.isOpen = true;
//         return nfts;
//     }

//     function checkBoxesIds() public view returns (uint256[] memory) {
//         require(ownedBoxes[msg.sender].length > 0, "you do not own any boxes");
//         return ownedBoxes[msg.sender];
//     }

//     function rngNFT() public returns (uint16) {
//         // function to generate a certain index
//     }
// }
