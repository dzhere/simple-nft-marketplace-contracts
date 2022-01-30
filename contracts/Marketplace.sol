//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract Marketplace is IERC721Receiver, IERC1155Receiver {
    struct Lot {
        address collection;
        uint256 tokenId;
        uint256 value;
        uint256 price;
        bool isOnSell;
    }

    mapping (address => Lot[]) private lots;
    mapping (address => uint256[]) private indexes;

    event ERC721Received(uint256 lotId, address operator, address from, uint256 tokenId, bytes data);
    event ERC1155Received(uint256 lotId, address operator, address from, uint256 id, uint256 value, bytes data);
    event ERC1155BatchReceived(uint256 lotId, address operator, address from, uint256[] ids, uint256[] values, bytes data);
    event Sell(uint256 lotId, address owner, uint256 price);
    event Buy(uint256 oldLotId, address owner, uint256 newLotId, address purchaser);
    event Withdraw(uint256 lotId, address owner);

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        Lot memory lot;
        lot.collection = operator;
        lot.tokenId = tokenId;
        lot.value = 1;

        uint256 lotId = addLot(from, lot);

        emit ERC721Received(lotId, operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        Lot memory lot;
        lot.collection = operator;
        lot.tokenId = id;
        lot.value = value;

        uint256 lotId = addLot(from, lot);

        emit ERC1155Received(lotId, operator, from, id, value, data);
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        for (uint256 i = 0; i < ids.length; i++) {
            Lot memory lot;
            lot.collection = operator;
            lot.tokenId = ids[i];
            lot.value = values[i];

            uint256 lotId = addLot(from, lot);
            emit ERC1155BatchReceived(lotId, operator, from, ids, values, data);
        }

        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function sell(uint256 lotId, uint256 price) external {
        Lot storage lot = lots[msg.sender][lotId];
        lot.price = price;
        lot.isOnSell = true;

        emit Sell(lotId, msg.sender, price);
    }

    function buy(address payable owner, uint256 lotId) external payable {
        Lot memory lot = lots[owner][lotId];

        require(lot.isOnSell, "Lot is not on trade");
        require(msg.value == lot.price, "ETH amount doesn't match");

        delete lots[owner][lotId];
        owner.transfer(msg.value);
        uint256 newLotId = addLot(msg.sender, lot);

        emit Buy(lotId, owner, newLotId, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function addLot(address owner, Lot memory lot) private returns (uint256 lotId) {
        lots[owner].push(lot);
        lotId = lots[owner].length - 1;
        indexes[owner].push(lotId);
    }
}