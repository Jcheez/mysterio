// SPDX-License-Identifier: MIT
pragma solidity >=0.4.20;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MysteryNFT is ERC721Enumerable{
    uint256[] public tokens;
    uint256 tokenId;
    mapping(uint256 => MystNFT) metadata; 

    constructor() ERC721("MysteryNFT", "MYSTNFT"){
        tokenId=0;
    }

    struct MystNFT{
        uint8 rarity;
        address[] contents;
    }


    function mint(uint8 rarity, address[] memory addresses) public {
        tokens.push(tokenId);
        MystNFT memory data = MystNFT(rarity, addresses);
        metadata[tokenId] = data;
        _mint(msg.sender, tokenId);
        tokenId+=1;
    }

    modifier numberExists(uint256 id){
        if (id<tokenId){
            _;
        }
    }

    function getRarity(uint256 id) public view numberExists(id) returns (uint8){
        return metadata[id].rarity;
    }

    function getContents(uint256 id) public view numberExists(id) returns (address[] memory){
        return metadata[id].contents;
    }
}