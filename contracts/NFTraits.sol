// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract NFTraits is VRFV2WrapperConsumerBase, ERC1155, Ownable, ERC1155Supply {
    event MintRandomRequest(uint256 requestId);

    string public name = 'NFTraits';
    string public symbol = 'Trait';

     struct mintStatus {
        uint256 fees;
        uint256[] ids;
        address sender;
        bool fulfilled;
    }

    mapping(uint256 => mintStatus) public statuses;

    // GORERLI 
    address constant linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant vrfWrapperAddress = 0x708701a1DfF4f478de54383E49a627eD4852C816;

    uint32 constant callbackGasLimit = 750_000;
    uint32 constant numWords = 10;
    uint16 constant requestConfirmations = 3;

    mapping(uint256 => bool) public minted1of1;

    constructor()
        VRFV2WrapperConsumerBase(linkAddress, vrfWrapperAddress)
        ERC1155("NFT") 
    {}

    // get/set renderer contract

    // | tokenlayers | Intrinsicnames | names | Description | additional Attributes |
    // function store (uint256 tokenId, uint256[18] calldata layers, uint256 intrinsicValue, string calldata name) public {}
    // function storeBatch //

    // Returns On-chain metadata from renderer contract
    function uri(uint256 tokenId) public view override(ERC1155) returns (string memory) { 
        // Read from SStore2 -> Call Render function with tokenId + layers uint256[18] 
    }

     function mintTraits() external returns (uint256) {
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );

        uint256[] memory ids = new uint256[](5);

        statuses[requestId] = mintStatus({
            fees: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            ids: ids,
            sender: msg.sender,
            fulfilled: false
        });

        emit MintRandomRequest(requestId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(statuses[requestId].fees > 0, "Request not found");

        statuses[requestId].fulfilled = true;
        for (uint256 i = 0; i < 5; i++) {
            uint256 groupId = randomWords[i] % 249;
            uint256 randomR = (randomWords[i+5] % 500)+1;
            uint256 rarityRank = randomRarity(randomR);
            uint256 tokenId = groupId * rarityRank;

            if(rarityRank == 5 && minted1of1[tokenId]) {
                tokenId = tokenId -1; // 1/1 taken downrank to ledgendary
            } else if(rarityRank == 5){
                minted1of1[tokenId] = true;
            }

            statuses[requestId].ids[i] = tokenId;
        }

        uint256[] memory amounts = new uint256[](5);
        for (uint256 i = 0; i < 5; i++) amounts[i] = 1;

        _mintBatch(statuses[requestId].sender, statuses[requestId].ids, amounts, '');
    }

    function getStatus(uint256 requestId)
        public
        view
        returns (mintStatus memory)
    {
        return statuses[requestId];
    }
    
    function randomRarity(uint256 input) internal pure returns(uint256){
        if(input < 6){
            return 5; // 5/500 -> 1%
        } else if (input < 26 ){
            return 4; // 5%
        } else if (input < 76 ){
            return 3; // 15%
        } else if (input < 226) {
            return 2; // 30%
        } else {
            return 1; // 50%
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}