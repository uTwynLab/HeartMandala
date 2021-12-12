// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HeartMandala.sol";
import "./utils/Math.sol";

/**
 * @dev Functionality of secondary market 
*/
contract SecondaryMarket is HeartMandala, Math {
    
    // Royalties of second market value
    uint256 public royalty;

    // NFT prices tokenId => price
    mapping (uint => uint) public prices;


    /**
     * @dev Emitted when seting new price for NFT.
     */
    event MarketSetPrice (address indexed owner, uint indexed tokenId, uint price);

    /**
     * @dev Emitted when selling NFT on secondary market.
     */
    event MarketSell (address indexed seller, address indexed buyer, uint indexed tokenId, uint price);


    constructor()
    {
        royalty = 3; // 2% TODO set real value 
    }


    /**
     * @dev Setting price of NFT by owner. If price is set bigger 0 it can be buyed by other user. 
    */
    function setPrice(uint _tokenId, uint _price)
        public isTokenExist(_tokenId) isTokenOwner(_tokenId)
    {
        require (_price >= 0, "SecondaryMarket: Price must be 0 or bigger");

        prices[_tokenId] = _price;
        
        emit MarketSetPrice (msg.sender, _tokenId, _price);
    }

    /**
     * @dev Sell of existing NFT 
    */
    function buyExistingNFT(uint _tokenId)
        public payable isTokenExist(_tokenId)
    {
        require (prices[_tokenId] > 0, "SecondaryMarket: Not for sale");
        require (msg.sender != ownerOf(_tokenId), "SecondaryMarket: You can't buy from yourself");
        require (msg.value == prices[_tokenId], "SecondaryMarket: You've sent not enough money");
    
        address payable _oldOwner = payable (ownerOf(_tokenId));

        // Сalculation of commission and payment amount
        uint _price = prices[_tokenId];
        uint _comission = safeDiv(safeMul(_price,royalty),100);
        uint _paymentSum = _price - _comission;

        // Payment to the owner
        _oldOwner.transfer(_paymentSum);

        // Transfer of NFT
        _transfer(_oldOwner, msg.sender, _tokenId);

        // Remove from sale
        prices[_tokenId] = 0;

        emit MarketSell (_oldOwner, msg.sender, _tokenId, _price);
    }
}