//SPDX-License-Identifier: Unlicense
//Contract from https://github.com/devbulat/nft-contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nft is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping (uint256 => string) private _tokenURIs;

    constructor() ERC721("NftItem", "NFTI") public {}

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "Token with this tokenId doesn't exist");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function mint(address user, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function getTokenUri(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token with this tokenId doesn't exist");

        string memory _tokenURI = _tokenURIs[tokenId];
        
        return _tokenURI;
    }
}