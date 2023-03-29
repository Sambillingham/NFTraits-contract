// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@0xsequence/sstore2/contracts/SSTORE2.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract TraitsMetadata { 
    struct SVGRowBuffer {
        string one; 
        string two; 
        string three;
        string four; 
        string five; 
        string six; 
        string seven; 
        string eight; 
    }

    struct SVGCursor {
        uint16 x;
        uint16 y;
    }

    string WHITE64 = "ZmZm";
    string G164 = "MzMz";
    string G264 = "OTk5";
    string G364 = "ZGRk";

    // consider best approach for storing 
    mapping(uint256 => uint256) intrinsicValues;
    mapping(uint256 => string) names;

    mapping(uint256 => address) tokenLayers;

    function store (uint256 groupId, uint256[8] calldata layers, uint256 intrinsicValue, string calldata name) public {
        tokenLayers[groupId] = SSTORE2.write(abi.encode(layers));

        // abi encode/decode with token layers?
        intrinsicValues[groupId] = intrinsicValue;
        names[groupId] = name;
    }
    
    function createTokenUri(uint256 tokenId) public view returns (string memory) {
        uint256 groupId = (tokenId - (tokenId % 5))/5; // base token in a group
        string[4] memory buffer = generateSvgData(groupId);
        string memory att = getAttributes(tokenId);
        string memory overlaySquare = overlay(tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    buffer[0],
                    buffer[1],
                    buffer[2],
                    buffer[3],
                    overlaySquare,
                    "PHN0eWxlPnJlY3Qge3dpZHRoOjEwcHg7aGVpZ2h0OjEwcHg7IH0gLm8geyBtaXgtYmxlbmQtbW9kZTogb3ZlcmxheTsgd2lkdGg6IDMyMHB4OyBoZWlnaHQ6IDMyMHB4OyB9IDwvc3R5bGU+PC9zdmc+IiwgICJuYW1lIjogIlRyYWl0cy4g", //style tag + name
                    names[groupId],// name here - needs to be pre-base64 encoded or padded with space char before encoding 
                    "IiwgImRlc2NyaXB0aW9uIjogIlRyYWl0cyIs", // description 
                    att // last (okay if it includes padding at the end )
                )
        );
    }

    // returns base 64 encoded overlay square based on tokenId
    function overlay(uint256 tokenid) public pure returns (string memory) {
        uint256 rarityLevel = tokenid % 5;
        string[5] memory overlayOptions = ['ICA8cmVjdCBjbGFzcz0nbycgZmlsbD0nIzI3N2ViOCcgIHg9JzAnICB5PScwJy8+', 'ICA8cmVjdCBjbGFzcz0nbycgZmlsbD0nIzI3Yjg1YScgIHg9JzAnICB5PScwJy8+', 'ICA8cmVjdCBjbGFzcz0nbycgZmlsbD0nI2Q2NTE1MScgIHg9JzAnICB5PScwJy8+', 'ICA8cmVjdCBjbGFzcz0nbycgZmlsbD0nI2Y3ZGQ1OScgIHg9JzAnICB5PScwJy8+', 'ICA8cmVjdCBjbGFzcz0nbycgZmlsbD0nIzc0MjdiOCcgIHg9JzAnICB5PScwJy8+'];
        return overlayOptions[rarityLevel];
    }
    
    function getAttributes(uint256 tokenid) public view returns (string memory){
        uint256 groupId = (tokenid - (tokenid % 5))/5; // base token in a group /5
        uint256 rarityLevel = tokenid % 5;
        string[5] memory rarity = ['common', 'uncommon', 'rare', 'ledgendary', 'unique'];
        string[11] memory iv = ['"0"','"1"', '"2"', '"3"', '"4"', '"5"', '"6"', '"7"', '"8"', '"9"', '"10"'];
        
        bytes memory attributes = abi.encodePacked(
            '"attributes": [ { "trait_type": "Rarity Level", "value": "',
            rarity[rarityLevel],
            '"},{"trait_type": "Intrinsic Value","value":',
            iv[intrinsicValues[groupId]], 
            '}]}'
        );
        return string(
            abi.encodePacked(
                Base64.encode(attributes)
            )
        );
    }

    function tokenSVG(uint256 groupId) public view returns (string memory) {
        string[4] memory buffer = generateSvgData(groupId);

        string memory svg = 
            string.concat(
                "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCA0ODAgNDgwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                buffer[0],
                buffer[1],
                buffer[2],
                buffer[3],
                "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4"
            );
        return svg;
    }

    function generateSvgData(uint256 groupId) private view returns (string[4] memory) {
        SVGCursor memory cursor;

        SVGRowBuffer memory cursorRow;

        string[8] memory bufferOfRows;
        uint8 indexIntoBufferOfRows;

        string[4] memory blockOfEightRows;
        uint8 indexIntoblockOfEightRows;

        // base64-encoded svg coordinates from 010 to 470
        string[48] memory coordinateLookup = [
            "MDAw", "MDEw", "MDIw", "MDMw", "MDQw", "MDUw", "MDYw", "MDcw", "MDgw", "MDkw", "MTAw", "MTEw", "MTIw", "MTMw", "MTQw", "MTUw", "MTYw", "MTcw", "MTgw", "MTkw", "MjAw", "MjEw", "MjIw", "MjMw", "MjQw", "MjUw", "MjYw", "Mjcw", "Mjgw", "Mjkw", "MzAw", "MzEw", "MzIw", "MzMw", "MzQw", "MzUw", "MzYw", "Mzcw", "Mzgw", "Mzkw", "NDAw", "NDEw", "NDIw", "NDMw", "NDQw", "NDUw", "NDYw", "NDcw"
        ];

        string[1024] memory colours  = getColoursFromLayers(groupId);

        for (uint256 row = 0; row < 32; row++) {
            cursorRow.one = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.two = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.three = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.four = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.five = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.six = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.seven = fourPixels(coordinateLookup, cursor, colours);
            cursor.x += 4;
            cursorRow.eight = fourPixels(coordinateLookup, cursor, colours);
            
            // Stack too deep if single list og string concat
            bufferOfRows[indexIntoBufferOfRows++] = string.concat(
                    cursorRow.one,
                    cursorRow.two,
                    cursorRow.three,
                    cursorRow.four,
                    cursorRow.five,
                    cursorRow.six,
                    cursorRow.seven,
                    cursorRow.eight
            );

            cursor.x = 0;
            cursor.y += 1;
            
            if (indexIntoBufferOfRows >= 8) {
                blockOfEightRows[indexIntoblockOfEightRows++] = string(
                    abi.encodePacked(
                        bufferOfRows[0],
                        bufferOfRows[1],
                        bufferOfRows[2],
                        bufferOfRows[3],
                        bufferOfRows[4],
                        bufferOfRows[5],
                        bufferOfRows[6],
                        bufferOfRows[7]
                    )
                );
                indexIntoBufferOfRows = 0;
            }
        }
        return blockOfEightRows;
    }
    function fourPixels(string[48] memory coordinateLookup, SVGCursor memory pos, string[1024] memory colours) internal pure returns (string memory) {
        return string.concat(
            "PHJlY3QgICBmaWxsPScj",
            colours[(pos.y * 32)+ pos.x],
            "JyAgeD0n",
            coordinateLookup[pos.x],
            "JyAgeT0n",
            coordinateLookup[pos.y],
            "JyAvPjxyZWN0ICBmaWxsPScj",
            colours[(pos.y * 32)+ pos.x +1],
            "JyAgeD0n",
            coordinateLookup[pos.x + 1],
            "JyAgeT0n",
            coordinateLookup[pos.y],
            "JyAvPjxyZWN0ICBmaWxsPScj",
            colours[(pos.y * 32)+ pos.x +2],
            "JyAgeD0n",
            coordinateLookup[pos.x + 2],
            "JyAgeT0n",
            coordinateLookup[pos.y],
            "JyAvPjxyZWN0ICBmaWxsPScj",
            colours[(pos.y * 32)+ pos.x +3],
            "JyAgeD0n",
            coordinateLookup[pos.x + 3],
            "JyAgeT0n",
            coordinateLookup[pos.y],
            "JyAgIC8+"
        );
    }

    function getColoursFromLayers (uint256 groupId) public view returns (string[1024] memory){
        bytes1[8] memory bitMask;
        bitMask[0] = (0x7F); // 01111111
        bitMask[1] = (0xBF); // 10111111
        bitMask[2] = (0xDF); // 11011111
        bitMask[3] = (0xEF); // 11101111
        bitMask[4] = (0xF7); // 11110111
        bitMask[5] = (0xFB); // 11111011
        bitMask[6] = (0xFD); // 11111101
        bitMask[7] = (0xFE); // 11111110
        
        string[1024] memory colours;

        uint8 bit1;
        uint8 bit2;
        
        uint256[8] memory layers = abi.decode( SSTORE2.read(tokenLayers[groupId]), (uint256[8]));

        for (uint256 l; l < 4; l++) {
            bytes32 layer1 = bytes32(uint256(layers[l]));
            bytes32 layer2 = bytes32(uint256(layers[l+4]));
            for (uint256 i; i < 32; i++) {
                for (uint256 b; b < bitMask.length; b++) {
                    bit1 = (bitMask[b] | bytes1(uint8(layer1[i])) == bytes1(uint8(0xFF))) ? 1 : 0;
                    bit2 = (bitMask[b] | bytes1(uint8(layer2[i])) == bytes1(uint8(0xFF))) ? 1 : 0;
                    
                    uint256 cid = (l*256)+(i*8)+b;

                    if(bit1 == 0 && bit2 == 0) colours[cid] = WHITE64;
                    if(bit1 == 1 && bit2 == 1) colours[cid] = G164;
                    if(bit1 == 1 && bit2 == 0) colours[cid] = G264;
                    if(bit1 == 0 && bit2 == 1) colours[cid] = G364;
                }
            }
        }
        return colours;
    }
}