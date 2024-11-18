// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract KaiaLearnNFT is ERC721 {
    using Strings for uint256;
    
    uint256 private _tokenIds;
    string private constant IMAGE_CID = "QmQg9eXeRwx4K9KRnaGNDNttMH4iTh5BwBpzmGGqn4EFan";
    
    struct Assignment {
        string title;
        string description;
        uint256 score;
        uint256 completedDate;
    }
    
    mapping(uint256 => Assignment) public assignments;
    mapping(uint256 => address) public studentAddresses;
    
    // Mapping để kiểm tra xem một địa chỉ đã mint NFT cho bài tập chưa
    mapping(address => mapping(string => bool)) public hasCompletedAssignment;
    // Mapping để kiểm tra xem bài tập đã tồn tại chưa
    mapping(string => bool) public assignmentExists;
    
    constructor() ERC721("KaiaLearn Certificate", "KAIA") {}
    
    function mintCertificate(
        string memory title,
        string memory description,
        uint256 score
    ) public returns (uint256) {
        
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        assignments[newTokenId] = Assignment({
            title: title,
            description: description,
            score: score,
            completedDate: block.timestamp
        });
        
        studentAddresses[newTokenId] = msg.sender;
        
        // Đánh dấu là đã hoàn thành bài tập này
        hasCompletedAssignment[msg.sender][title] = true;
        // Đánh dấu bài tập đã tồn tại
        assignmentExists[title] = true;
        
        _safeMint(msg.sender, newTokenId);
        
        return newTokenId;
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return studentAddresses[tokenId] != address(0);
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        Assignment memory assignment = assignments[tokenId];
        address student = studentAddresses[tokenId];
        
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "KaiaLearn Certificate #',
                    tokenId.toString(),
                    '", "description": "Certificate of completion for KaiaLearn course", ',
                    '"image": "ipfs://',
                    IMAGE_CID,
                    '", "attributes": [',
                    '{"trait_type": "Title", "value": "',
                    assignment.title,
                    '"}, {"trait_type": "Description", "value": "',
                    assignment.description,
                    '"}, {"trait_type": "Score", "value": "',
                    Strings.toString(assignment.score),
                    '"}, {"trait_type": "Completion Date", "value": "',
                    Strings.toString(assignment.completedDate),
                    '"}, {"trait_type": "Student Address", "value": "',
                    Strings.toHexString(uint256(uint160(student)), 20),
                    '"}]}'
                )
            ))
        );
        
        return string(abi.encodePacked('data:application/json;base64,', json));
    }
}

/// @notice Base64 encoding/decoding library
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        uint256 len = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(len);

        uint256 i;
        uint256 j = 0;
        uint256 n = data.length;

        while (i < n) {
            uint256 a = i + 1 < n ? uint8(data[i + 1]) : 0;
            uint256 b = i + 2 < n ? uint8(data[i + 2]) : 0;

            uint256 enc1 = uint8(data[i]) >> 2;
            uint256 enc2 = ((uint8(data[i]) & 3) << 4) | (a >> 4);
            uint256 enc3 = ((a & 15) << 2) | (b >> 6);
            uint256 enc4 = b & 63;

            result[j]     = TABLE[enc1];
            result[j + 1] = TABLE[enc2];
            result[j + 2] = TABLE[enc3];
            result[j + 3] = TABLE[enc4];

            i += 3;
            j += 4;
        }

        return string(result);
    }
}
