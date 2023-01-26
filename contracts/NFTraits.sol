// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

interface ERC721 {
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface Metadata {
    function createTokenUri(uint256 tokenId) external view returns (string memory);
}

contract NFTraits is VRFV2WrapperConsumerBase, ERC1155, Ownable, ERC1155Supply {

    constructor(address _linkAddress,address _vrfWrapperAddress)
        VRFV2WrapperConsumerBase(_linkAddress, _vrfWrapperAddress)
        ERC1155("NFT") 
    {}

    event MintRandomRequest(uint256 requestId);
    event OpenStatus(bool status);
    event MintRequestFulfilled(uint256 requestId, uint256[] ids);

    string public name = 'NFTraits';
    string public symbol = 'Trait';

    struct mintStatus {
        uint256 fees;
        uint256[] ids;
        address sender;
        bool fulfilled;
    }
    mapping(uint256 => mintStatus) public statuses;

    struct Season {
        uint256 id;
        address metadataAddress;
    }
    mapping(uint256 => Season) public seasons;

    // Track Free Mints 
    mapping(uint256 => mapping(uint256 => bool)) public BlergFreeMints;

    uint32 public callbackGasLimit = 800_000; 
    uint32 constant numWords = 8;
    uint16 constant requestConfirmations = 3;

    address blergsTokenAddress; 

    mapping(uint256 => bool) public minted1of1;

    uint256 constant RARITY_MODIFIER_PERCENTAGE = 33;
    uint256 constant BATCH_SIZE = 8; 
    uint256[] public maxMintsPerSeason = [0, 1000, 3500, 7500, 11500, 19500, 35500];
    uint256 public activeSeason = 1;
    uint256 public batchesMinted = 0;

    uint16[5] groupIdMin = [0, 250, 500, 1500, 2750];
    uint16[5] groupIdMax = [250, 500, 1500, 2750, 5000];

    uint16[5] options = [1,10,100,1000,10000];
    uint256[] levels;

    uint256 public mintPrice = 0.001 ether;
    bool public OPEN = false;

    function addSeason(uint256 _seasonId, address _metadataAddress) external onlyOwner () {
        seasons[_seasonId] = Season({
            id: _seasonId,
            metadataAddress: _metadataAddress
        });
    }

    function setActiveSeason(uint256 _seasonId) external onlyOwner () {
        activeSeason = _seasonId;
    }

    function setBlergsTokenAddress(address _blergsTokenAddress) external onlyOwner () {
        blergsTokenAddress = _blergsTokenAddress;
    }

    function setNewPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }
    
    function flipOpenState() external onlyOwner {
        OPEN = !OPEN;
        emit OpenStatus(OPEN);
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner () {
        callbackGasLimit = _callbackGasLimit;
    }

    function uri(uint256 tokenId) public view override returns (string memory tokenUri) {
        uint256 groupId = (tokenId - (tokenId % 5))/5; // base token in a group

        for (uint256 i = 0; i < 5; i++) {
            if( groupId >= groupIdMin[i] && groupId < groupIdMax[i]) {
                return Metadata(seasons[i+1].metadataAddress).createTokenUri(tokenId);
            }
        }
    }

    function mintTraitsWithBlerg(uint256 tokenId) external returns (uint256) {
        require(OPEN , "MINTING - NOT OPEN");
        require(BlergFreeMints[tokenId][activeSeason] != true, "Mint Used");
        require(ERC721(blergsTokenAddress).ownerOf(tokenId) == msg.sender, "Not Owner of Token");
        require(batchesMinted < maxMintsPerSeason[activeSeason], "MAX minted during Season");

        BlergFreeMints[tokenId][activeSeason] = true;
        return callVrfMint();
    }
    
    function mintTraits() payable external returns (uint256) {
        require(OPEN , "MINTING - NOT OPEN");
        require(msg.value >= mintPrice, "Not enough ETH sent");
        require(batchesMinted < maxMintsPerSeason[activeSeason], "MAX minted during Season");
        return callVrfMint();
    }

    function callVrfMint() private returns (uint256) {
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );

        uint256[] memory ids = new uint256[](8);

        statuses[requestId] = mintStatus({
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            ids: ids,
            sender: msg.sender,
            fulfilled: false
        });

        emit MintRandomRequest(requestId);
    }
    
    function mintTraitsTest(uint256 _requestId, uint256[] memory _randomWords) public payable {
        require(msg.value >= mintPrice, "Not enough ETH sent");
        require(OPEN , "MINTING - NOT OPEN");
        require(batchesMinted < maxMintsPerSeason[activeSeason], "MAX minted during Season");

        uint256[] memory ids = new uint256[](8);

        statuses[_requestId] = mintStatus({
            fees: 1_500_000,
            ids: ids,
            sender: msg.sender,
            fulfilled: false
        });

        fulfillRandomWords(_requestId, _randomWords);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(statuses[requestId].fees > 0, "Request not found");

        uint256 SEASON = seasonReducer(activeSeason, randomWords[randomWords[0] % BATCH_SIZE]);
        
        statuses[requestId].fulfilled = true;
        for (uint256 i = 0; i < BATCH_SIZE; i++) {
            uint256 groupId = (randomWords[i] % groupIdMax[SEASON-1]) + groupIdMin[SEASON-1];
            uint256 randomR = (randomWords[BATCH_SIZE-i-1] % 500)+1; // 1 - 500
            uint256 rarityRank = randomRarity(randomR, statuses[requestId].sender);
            uint256 tokenId = (groupId*5) + rarityRank;

            if(rarityRank == 4 && minted1of1[groupId]) {
                tokenId = tokenId -1; // 1/1 taken downrank to ledgendary
                console.log("tokenId: ", tokenId);
            } else if(rarityRank == 4){ 
                minted1of1[tokenId] = true;
            }

            statuses[requestId].ids[i] = tokenId;
        }

        uint256[] memory amounts = new uint256[](8);
        for (uint256 i = 0; i < BATCH_SIZE; i++) amounts[i] = 1;

        batchesMinted += 1;
        _mintBatch(statuses[requestId].sender, statuses[requestId].ids, amounts, '');
        
        emit MintRequestFulfilled(requestId, statuses[requestId].ids);
    }
    
    function randomRarity(uint256 input, address sender) internal view returns(uint256){
        uint256 COUNT = ERC721(blergsTokenAddress).balanceOf(sender);
        uint256 rarityBonus = 100 + (RARITY_MODIFIER_PERCENTAGE * COUNT);
        if(input*100 < 6 * rarityBonus){
            return 4; // < 600 / 50000 ~ 5%
        } else if (input*100 < 26 * rarityBonus){
            return 3; // < 2600 / 50000 ~ 2.5%
        } else if (input*100 < 76 * rarityBonus){
            return 2; // < 7600 / 50000 ~ 7.5%
        } else if (input*100 < 226 * rarityBonus) { 
            return 1; // < 22600 / 50000 ~ 25%
        } else {
            return 0; // 50%
        }
    }

    function seasonReducer(uint256 currentSeason, uint256 randomNumber) internal returns(uint256){
        if (currentSeason == 1) return 1;
        levels.push(1);
        uint256 r = randomNumber % options[currentSeason-1];
        for (uint256 i = 2; i <= currentSeason; i++) {
            uint256 powerMultiplier = (i-2);
            uint256 upPower = 9*(10**powerMultiplier);
            levels.push(upPower);
        }
        
        for (uint256 k = 0; k < levels.length; k++) {
            if(r < levels[k]) {
                return k+1;
            } 
        }
        return levels.length;
    }

    // utility function for checking chainlink VRF status
    // function getStatus(uint256 requestId) public view returns (mintStatus memory)
    // {
    //     return statuses[requestId];
    // }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function withdraw() public onlyOwner() {
        uint256 balance = address(this).balance;
        (bool success, ) = (msg.sender).call{ value: balance }("");
        require(success, "Failed to widthdraw Ether");
    }
}