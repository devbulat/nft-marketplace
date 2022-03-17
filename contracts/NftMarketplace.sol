//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Nft.sol";
import "./Devbulat_ERC20.sol";

struct Bid {
    address user;
    uint256 price;
    uint256 bidNumber;
}

uint constant THREE_DAYS = 259200;

contract NftMarketplace {
    address private _seller;
    Nft private _nftContract;
    DevbulatERC20 private _erc20Token;
    mapping (uint256 => uint256) private _orders;
    mapping (uint256 => uint256) private _auctionOrders;
    mapping (uint256 => Bid) private _auctionBids;
    uint256 private _auctionStartDate;

    constructor(address nftContract, address erc20Token) {
        _nftContract = Nft(nftContract);
        _erc20Token = DevbulatERC20(erc20Token);
        _seller = msg.sender;
    }

    function createItem(string memory tokenURI) public returns (uint256) {
        require(msg.sender == _seller, "You are not seller!");

        uint256 itemId = _nftContract.mint(_seller, tokenURI);

        return itemId;
    }

    function listItem(uint256 tokenId, uint256 price) public {
        require(msg.sender == _seller, "You are not seller!");
        _orders[tokenId] = price;
    }

    function cancel(uint256 tokenId) public {
        delete _orders[tokenId];
    }

    function buyItem(uint256 tokenId) public {
        _erc20Token.transferFrom(msg.sender, _seller, _orders[tokenId]);
        _nftContract.transferFrom(_seller, msg.sender, tokenId);
    }

    function listItemOnAuction(uint256 tokenId, uint256 minPrice) public {
        require(msg.sender == _seller, "You are not seller!");

        _auctionOrders[tokenId] = minPrice;
        _auctionStartDate = block.timestamp;
    }

    function returnToLastBidder(uint256 tokenId) private {
        _erc20Token.transferFrom(address(this), _auctionBids[tokenId].user, _auctionBids[tokenId].price);
    }

    function makeBid(uint256 tokenId, uint256 price) public {
        if (_auctionBids[tokenId].price > 0) {
            returnToLastBidder(tokenId);
        }

        _erc20Token.transferFrom(msg.sender, address(this), price);
        uint256 bidNumber = _auctionBids[tokenId].bidNumber;
        _auctionBids[tokenId] = Bid(msg.sender, price, bidNumber + 1);
    } 

    function finishAuction(uint256 tokenId) public {
        require(msg.sender == _seller, "You are not seller!");
        require(block.timestamp - _auctionStartDate > THREE_DAYS, "Auction is proceed!");

        if (_auctionBids[tokenId].bidNumber >= 2) {
            _erc20Token.transferFrom(address(this), _seller, _auctionBids[tokenId].price);
            _nftContract.transferFrom(_seller, _auctionBids[tokenId].user, tokenId);
        } else {
            returnToLastBidder(tokenId);
        }
    }
}
