pragma solidity >=0.4.20;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MysteryNFT is ERC721Enumerable{
    // bytes32[] public tokens;
    // mapping(bytes32 => bool) exists;
    uint256[] public tokenId; 
    mapping(uint256 => bool) exists;

    constructor() ERC721("MysteryNFT", "MYSTNFT"){
    }

    //params: maybe generate hash for token based on inputs and rarity?
    function mint(uint256 num) public{
        // bytes32 joined = bytes32(this.generateId(rarity, inputs));
        // bytes32 id = keccak256(joined);
        // tokens.push(joined);
        // exists[joined] = true;
        // _mint(msg.sender, uint256(joined));
        require(!exists[num]);
        tokenId.push(num);
        exists[num]=true;
        _mint(msg.sender, num);
    }

    function generateId(uint8 rarity, string[] calldata words) external pure returns (bytes memory) {
        bytes memory output = abi.encodePacked(rarity);
        for (uint256 i = 0; i < words.length; i++) {
            output = abi.encodePacked(output, words[i]);
        }
        return output;
    }
}