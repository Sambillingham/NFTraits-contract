// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract NFTraits is ERC1155, Ownable, ERC1155Supply {
    constructor() ERC1155("NFTraits") {}

    string public name = 'NFTraits';
    string public symbol = 'Trait';

    // get/set renderer contract

    // | tokenlayers | Intrinsicnames | names | Description | additional Attributes |
    // function store (uint256 tokenId, uint256[18] calldata layers, uint256 intrinsicValue, string calldata name) public {}
    // function storeBatch //

    // Returns On-chain metadata from renderer contract
    function uri(uint256 tokenId) public view override(ERC1155) returns (string memory) { 
        // Read from SStore2 -> Call Render function with tokenId + layers uint256[18] 
    }


    function randomRarity(uint256 input) internal returns(uint256){
        // VRF -> 
        uint256 intrinsic = uint(blockhash(block.number -1 )) % 250 ; 
        // intrinsic rarity is defined by the artist
        uint256 rarityChance = uint(blockhash(block.number -1 )) % 500;
        uint256 rarity;

        if(rarityChance < 2){
            rarity = 4; // 1/500 -> 0.002%
        } else if (rarityChance < 25 ){
            rarity = 3; // 5%
        } else if (rarityChance < 100 ){
            rarity = 2; // 15%
        } else if (rarityChance < 250) {
            rarity = 1; // 30%
        } else {
            rarity = 0; // 50%
        }
        uint256 tokenGroup = (intrinsic * 5);
        console.log('tokenGroup: ', tokenGroup);
        console.log('Rarity Level: ', rarity);
        return tokenGroup + rarity;
    }

    function mintBatch() public {
        uint256[] memory ids = new uint256[](8);
        uint256[] memory amounts = new uint256[](8);
        for (uint256 i = 0; i < 1; i++) amounts[i] = 1;
        for (uint256 i = 0; i < 1; i++) {
            ids[i] = randomRarity(i);
            console.log('TokenID: ',ids[i]);
        }

        _mintBatch(msg.sender, ids, amounts, '');
    }
    

    
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}