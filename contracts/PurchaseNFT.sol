pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract PurchaseNFT {
    
    uint private _listingId = 0;
	mapping(uint => Listing) private _listings; // get the listing from listing id
    MysteryToken mysteryTokenContract;

    constructor(MysteryToken mysteryTokenAddress) {
        mysteryTokenContract = mysteryTokenAddress;
    }

    enum ListingStatus {
		Active,
		Sold
	}

	struct Listing {
		ListingStatus status;
		address seller;
		uint tokenId;
		uint price;
	}

    event Listed(
		uint listingId,
		address seller,
		uint tokenId,
		uint price
	);

	event Bought(
		uint listingId,
		uint tokenId,
		uint price
	);


    function listNFT(uint tokenId, uint price) external {
		//transferring the nft from the seller to the contract
        _transferFrom(msg.sender, address(this), tokenId);
        
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
			tokenId,
			price
		);
	}

    function buyNFT(uint listingId) private payable {
		// get the listing 
        Listing storage listing = _listings[listingId];

        // check if listing is active 
		require(listing.status == ListingStatus.Active, "Listing is not available anymore");

		

        // set to sold 
		listing.status = ListingStatus.Sold;

        // transfer the nft to the msg.sender (buyer)
		_transferFrom(address(this), msg.sender, listing.tokenId);
		
        // require(msg.value >= listing.price, "Insufficient payment");
        // payment by mystery token 
        mysteryTokenContract.transferCreditFrom(msg.sender, listing.seller, price);

        

		emit Sale(
			listingId,
			msg.sender,
			listing.token,
			listing.tokenId,
			listing.price
		);

        // add the nft into our own storage 
        const nftToAdd = new OwnedNft(address(this), listing.price, listing.tokenId, false);
        nftToAdd.add(nftToAdd.price, nftToAdd.address, nftToAdd.tokenId, nftToAdd.isValued);
	}

}