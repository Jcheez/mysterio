// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "./MysteryToken.sol";
import "./ownedNFTs.sol";
import "./ERC20.sol";
import "./MysteryStaking.sol";




contract PurchaseNFT {
    
    uint private _listingId = 0;
	mapping(uint => Listing) private _listings; // get the listing from listing id
  	OwnedNFTs ownedNFTContract; 
	MysteryStaking mysterystakingInstance;


    constructor(OwnedNFTs ownedNFTsAddress,MysteryStaking mysterystaking) {
        mysterystakingInstance = mysterystaking;
        ownedNFTContract = ownedNFTsAddress;
    }

    enum ListingStatus {Active,Sold}

	struct Listing {
		ListingStatus status;
		address seller;
        	address token;
		uint tokenId;
		uint price;
	}

    event Listed(uint listingId, address seller, address token, uint tokenId, uint price);

    event Bought(uint listingId, address buyer, address token, uint tokenId, uint price);


    function listNFT(address token, uint tokenId, uint price) external {
		//transferring the nft from the seller to the contract
        IERC721(token).transferFrom(IERC721(token).ownerOf(tokenId), address(this), tokenId);
        
        // create a new listing
		Listing memory listing = Listing(
			ListingStatus.Active,
			msg.sender,
            token,
			tokenId,
			price
		);

		_listingId++;

		_listings[_listingId] = listing;

		emit Listed(
			_listingId,
			msg.sender,
			token,
			tokenId,
			price
		);
	}

    function buyNFT(uint listingId) public payable {
		// get the listing 
        Listing storage listing = _listings[listingId];

		require(msg.sender != listing.seller, "Buyer cannot be the seller of the NFT");

        // check if listing is active 
		require(listing.status == ListingStatus.Active, "Listing is not available anymore");

		//check if enough money 
		// mysterystakingInstance.getMYST(msg.sender, msg.value);
		require(mysterystakingInstance.getERCInstance().balanceOf(msg.sender) >= listing.price, 'Not enough money');
	

        // set to sold 
		listing.status = ListingStatus.Sold;

        // transfer the nft to the msg.sender (buyer)
		IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenId);
		
        // require(msg.value >= listing.price, "Insufficient payment");
		
        mysterystakingInstance.getERCInstance().transferFrom(msg.sender, listing.seller, listing.price);
   

		emit Bought(
			listingId,
			msg.sender,
			listing.token,
			listing.tokenId,
			listing.price
		);

        // add the nft into our own storage 
        ownedNFTContract.add(listing.price, listing.token, listing.tokenId, false);
	}

}
