// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SampleNFT is ERC721, Ownable {
    address payable public _owner;
    uint256 totalSupply;

    constructor() ERC721("YOUR TOKEN", "TOKEN") {
        _owner = payable(msg.sender);
    }

    function mint(address receiver)
        public
        onlyOwner
        returns (bool)
    {
        uint256 _tokenId = totalSupply;
        totalSupply += 1;
        _mint(receiver, _tokenId);
        return true;
    }

    // function buy(uint256 _id) external payable {
    //     _validate(_id);
    //     _trade(_id);
    //     emit Purchase(msg.sender, price[_id], _id, tokenURI(_id));
    // }

    // function _validate(uint256 _id) internal {
    //     require(_exists(_id), "Error, wrong Token id");
    //     require(!sold[_id], "Error, Token is sold");
    //     require(msg.value >= price[_id], "Error, Token costs more");
    // }

    function _trade(uint256 _id) internal {
        _transfer(address(this), msg.sender, _id);
        _owner.transfer(msg.value);
    }
}
