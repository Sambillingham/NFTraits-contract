// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@0xsequence/sstore2/contracts/SSTORE2.sol";

contract NFTraits is VRFV2WrapperConsumerBase, ERC1155, Ownable, ERC1155Supply {
    event MintRandomRequest(uint256 requestId);

    // string public name = 'NFTraits';
    // string public symbol = 'Trait';

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

    // Mumbai
    // address constant linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    // address constant vrfWrapperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

    uint32 constant callbackGasLimit = 1_500_000;
    uint32 constant numWords = 10;
    uint16 constant requestConfirmations = 3;

    mapping(uint256 => bool) public minted1of1;
    // constructor()
    //     VRFV2WrapperConsumerBase(linkAddress, vrfWrapperAddress)
    //     ERC1155("NFT") 
    // {}
    //  --> 
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

    constructor()
        VRFV2WrapperConsumerBase(linkAddress, vrfWrapperAddress)
        ERC1155("NFT") 
    {}

    mapping(uint256 => address) tokenLayers;

    // consider best approach for storing 
    mapping(uint256 => uint256) intrinsicValues;
    mapping(uint256 => string) names;

    address[] private _tokenDatas;

    function store (uint256 groupId, uint256[18] calldata layers, uint256 intrinsicValue, string calldata name) public {
        tokenLayers[groupId] = SSTORE2.write(abi.encode(layers));

        // abi encode/decode with token layers?
        intrinsicValues[groupId] = intrinsicValue;
        names[groupId] = name;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {

        uint256 groupId = (tokenId - (tokenId % 5))/5; // base token in a group
        string[6] memory buffer = generateSvgData(groupId);
        string memory att = getAttributes(tokenId);
        string memory overlaySquare = overlay(tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCA0ODAgNDgwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    buffer[0],
                    buffer[1],
                    buffer[2],
                    buffer[3],
                    buffer[4], 
                    buffer[5],
                    overlaySquare,
                    "PHN0eWxlPnJlY3Qge3dpZHRoOjEwcHg7aGVpZ2h0OjEwcHg7IH0gLm8geyBtaXgtYmxlbmQtbW9kZTogb3ZlcmxheTsgd2lkdGg6IDQ4MHB4OyBoZWlnaHQ6IDQ4MHB4OyB9IDwvc3R5bGU+PC9zdmc+IiwgICJuYW1lIjogIlRyYWl0cy4g", //style tag + name
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
        
        // console.log(tokenid);
        // console.log('group', groupId);
        // console.log('iv', intrinsicValues[groupId]);
        console.log('iv string', iv[intrinsicValues[groupId]]);

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
        // 6 lots of 8 rows 
        string[6] memory buffer = generateSvgData(groupId);

        string memory svg = 
            string.concat(
                    "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCA0ODAgNDgwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    buffer[0],
                    buffer[1],
                    buffer[2],
                    buffer[3],
                    buffer[4], 
                    buffer[5],  
                    "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4"
            );
            console.log('GAS:: ', gasleft());
        return svg;
    }


    function generateSvgData(uint256 groupId) private view returns (string[6] memory) {
        SVGCursor memory cursor;

        SVGRowBuffer memory cursorRow;

        string[8] memory bufferOfRows;
        uint8 indexIntoBufferOfRows;

        string[6] memory blockOfEightRows;
        uint8 indexIntoblockOfEightRows;

        // base64-encoded svg coordinates from 010 to 470
        string[48] memory coordinateLookup = [
            "MDAw", "MDEw", "MDIw", "MDMw", "MDQw", "MDUw", "MDYw", "MDcw", "MDgw", "MDkw", "MTAw", "MTEw", "MTIw", "MTMw", "MTQw", "MTUw", "MTYw", "MTcw", "MTgw", "MTkw", "MjAw", "MjEw", "MjIw", "MjMw", "MjQw", "MjUw", "MjYw", "Mjcw", "Mjgw", "Mjkw", "MzAw", "MzEw", "MzIw", "MzMw", "MzQw", "MzUw", "MzYw", "Mzcw", "Mzgw", "Mzkw", "NDAw", "NDEw", "NDIw", "NDMw", "NDQw", "NDUw", "NDYw", "NDcw"
        ];

        string[2304] memory colours  = getColoursFromLayers(groupId);

        for (uint256 row = 0; row < 48; row++) {
            
            cursorRow.one = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.two = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.three = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.four = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.five = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.six = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.seven = sixPixels(coordinateLookup, cursor, colours);
            cursor.x += 6;
            cursorRow.eight = sixPixels(coordinateLookup, cursor, colours);
            
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
                console.log('GAS:: ', gasleft());
                indexIntoBufferOfRows = 0;
            }
        }
        console.log('GAS:: ', gasleft());
        return blockOfEightRows;
    }
    
    function sixPixels(string[48] memory coordinateLookup, SVGCursor memory pos, string[2304] memory colours) internal pure returns (string memory) {
        return
            string.concat(
                string.concat(
                    "PHJlY3QgICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x],
                    "JyAgeD0n",
                    coordinateLookup[pos.x],
                    "JyAgeT0n",
                    coordinateLookup[pos.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x +1],
                    "JyAgeD0n",
                    coordinateLookup[pos.x + 1],
                    "JyAgeT0n",
                    coordinateLookup[pos.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x +2],
                    "JyAgeD0n",
                    coordinateLookup[pos.x + 2],
                    "JyAgeT0n",
                    coordinateLookup[pos.y]
                ),
                string.concat(
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x +3],
                    "JyAgeD0n",
                    coordinateLookup[pos.x + 3],
                    "JyAgeT0n",
                    coordinateLookup[pos.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x +4],
                    "JyAgeD0n",
                    coordinateLookup[pos.x + 4],
                    "JyAgeT0n",
                    coordinateLookup[pos.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    colours[(pos.y * 48)+ pos.x +5],
                    "JyAgeD0n",
                    coordinateLookup[pos.x + 5],
                    "JyAgeT0n",
                    coordinateLookup[pos.y],
                    "JyAgIC8+"
                )
            );
    }

    function getColoursFromLayers (uint256 groupId) public view returns (string[2304] memory){
        bytes1[8] memory bitMask;
        bitMask[0] = (0x7F); // 01111111
        bitMask[1] = (0xBF); // 10111111
        bitMask[2] = (0xDF); // 11011111
        bitMask[3] = (0xEF); // 11101111
        bitMask[4] = (0xF7); // 11110111
        bitMask[5] = (0xFB); // 11111011
        bitMask[6] = (0xFD); // 11111101
        bitMask[7] = (0xFE); // 11111110
        
        string[2304] memory colours;

        uint8 bit1;
        uint8 bit2;
        
        uint256[18] memory layers = abi.decode( SSTORE2.read(tokenLayers[groupId]), (uint256[18]));

        for (uint256 l; l < 9; l++) {
            bytes32 layer1 = bytes32(uint256(layers[l]));
            bytes32 layer2 = bytes32(uint256(layers[l+9]));
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
    // --> 






    // get/set renderer contract

    // | tokenlayers | Intrinsicnames | names | Description | additional Attributes |
    // function store (uint256 tokenId, uint256[18] calldata layers, uint256 intrinsicValue, string calldata name) public {}
    // function storeBatch //

    // Returns On-chain metadata from renderer contract
    // function uri(uint256 tokenId) public pure override(ERC1155) returns (string memory) { 
    //     // Read from SStore2 -> Call Render function with tokenId + layers uint256[18] 

    //     string memory svgStart = "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' shape-rendering='crispEdges' viewBox='0 0 500 500'><text style='white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 271.5px;' x='45.881' y='346.563'>";
    //     string memory svgEnd = "</text></svg>";
    //     // string memory svg64 = Base64.encode(abi.encodePacked(svgStart,Strings.toString(tokenId),svgEnd));
    //     string memory svg = string(abi.encodePacked(svgStart,Strings.toString(tokenId),svgEnd));

    //     // Tmp
    //     return string(abi.encodePacked('data:application/json;base64,', Base64.encode(abi.encodePacked(
    //         '{',
    //             '"name": "', Strings.toString(tokenId), '", ',
    //             // '"image_data": "data:image/svg+xml;base64,', svg64, '", ',
    //             '"image_data": "', svg, '", ',
    //             getAttributes(tokenId),
    //         '}'))
    //     ));
    // }

    // function getAttributes(uint256 tokenid) public pure returns (string memory){
    //     uint256 rarityLevel = tokenid % 5;
    //     string[5] memory rarity = ['common', 'uncommon', 'rare', 'ledgendary', 'unique'];

    //     return string(abi.encodePacked(
    //         '"attributes": [ { "trait_type": "Rarity Level", "value": "',
    //         rarity[rarityLevel],
    //         '"}]'
    //     ));
    // }

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
            uint256 groupId = randomWords[i] % 4;
            uint256 randomR = (randomWords[i+5] % 500)+1;
            uint256 rarityRank = randomRarity(randomR);
            uint256 tokenId = (groupId*5) + rarityRank;

            if(rarityRank == 5 && minted1of1[groupId]) {
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
            return 4; // 5/500 -> 1%
        } else if (input < 26 ){
            return 3; // 5%
        } else if (input < 76 ){
            return 2; // 15%
        } else if (input < 226) {
            return 1; // 30%
        } else {
            return 0; // 50%
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}


library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}