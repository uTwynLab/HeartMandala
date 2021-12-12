// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @dev Functionality of first sale of NFT
*/
contract HeartMandala is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    // Counter of tokens id
    Counters.Counter private _tokenIds;

    // Maximum amount of NFT
    uint public mintVolume;

    // Cost of NFT on first sell
    uint public nftPrice;

    // Is the sale of new NFT available
    bool public saleIsActive;

    // Is the URI of medatadata set
    mapping (uint => bool) isURIChange;

    // Descriptions of NFTs
    mapping (uint => string) public nftDescriptions;


    /**
     * @dev Throws if token is not exist
     */
    modifier isTokenExist(uint _tokenId) {
        require(_exists(_tokenId), "HeartMandala: Token is not exist");
        _;
    }

    /**
     * @dev Throws if not token owner
     */
    modifier isTokenOwner(uint _tokenId) {
        require (ownerOf(_tokenId) == msg.sender, "HeartMandala: You are not the owner");
        _;
    }


    constructor() ERC721("HeartMandala", "HeartM") {
        nftPrice = 0.01 ether; // TODO Change to real
        mintVolume = 10000; // TODO Change to real
        saleIsActive = false;
    }


    /**
     * @dev Emitted when seting new price for NFT.
     */
    event MintSetPrice (uint price);

    /**
     * @dev Emitted when seting status of selling of NFT.
     */
    event MintSetSellingStatus (bool status);

    /**
     * @dev Emitted when selling NFT on secondary market.
     */
    event MintSell (address indexed buyer, uint indexed tokenId, uint price);

    /**
     * @dev Emitted when setting description of NFT.
     */
    event OwnerSetNFTDescription (uint indexed _tokenId, string _decription);


    /**
     * @dev Withdraw of money from contract
     */
    function withdraw() public onlyOwner {
        uint _balance = address(this).balance;
        address payable _reciver = payable(msg.sender);
        _reciver.transfer(_balance);
    }

    /**
     * @dev Set price of initial sale
     */
    function setFirstSalePrice(uint _price)
        public onlyOwner
    {
        require (_price > 0, "HeartMandala: Price must be bigger then 0");

        nftPrice = _price;

        emit MintSetPrice (_price);
    }
    
    /**
     * @dev Set availabilit of initial sale
     */
    function setSaleStatus(bool _status)
        public onlyOwner
    {
        saleIsActive = _status;

        emit MintSetSellingStatus (_status);        
    }

    /**
     * @dev Set description of NFT
     */
    function setNFTDescription(uint _tokenId, string memory _decription)
        public isTokenOwner(_tokenId) isTokenExist(_tokenId)
    {
        nftDescriptions[_tokenId] = _decription;

        emit OwnerSetNFTDescription (_tokenId, _decription);        
    }

    /**
     * @dev First sale and mint of NFT
     */
    function buyNewNFT(string memory _description)
        public payable
        returns (uint)
    {
        require (saleIsActive == true, "HeartMandala: Sales are not active");
        require (msg.value == nftPrice, "HeartMandala: Not enough money");
        require (_tokenIds.current()+1 <= mintVolume, "HeartMandala: Limit of minted NFT");

        _tokenIds.increment();

        uint _newItemId = _tokenIds.current();
        _mint(msg.sender, _newItemId);
        setNFTDescription(_newItemId, _description);

        emit MintSell (msg.sender, _newItemId, nftPrice);

        return _newItemId;
    }
    
    /**
     * @dev Setting URI of NFT metadata. Can be used only ones.
     */
    function setURI(uint _tokenId, string memory _tokenURI)
        public onlyOwner isTokenExist(_tokenId)
    {
        require (isURIChange[_tokenId] != true, "HeartMandala: Can be changed only once!");

        _setTokenURI(_tokenId, _tokenURI);
        isURIChange[_tokenId] = true;
    }
    
    /**
     * @dev Getting all nft of user
     */
    function getNFTsByOwner(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](balanceOf(_owner));
        uint counter = 0;
        for (uint i = 1; i <= _tokenIds.current(); i++) {
            if (ownerOf(i) == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        
        return result;
    }

    /**
     * @dev Getting current count of minted NFT
     */
    function getNFTCount() public view returns (uint) {
        return _tokenIds.current();
    }
}