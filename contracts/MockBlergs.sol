// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MockBlergs is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Bl", "B") {}

    function mint() public {
        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);
    
        _tokenIds.increment();
    }
    
}
