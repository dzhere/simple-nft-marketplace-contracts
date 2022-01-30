//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Launchpad {
    event ERC721ContractDeployment(address contract_);
    event ERC1155ContractDeployment(address contract_);

    function createERC721Contract(string memory name_, string memory symbol_) public returns (address deployedContractAddress) {
        deployedContractAddress = address(new ERC721(name_, symbol_));
        emit ERC721ContractDeployment(deployedContractAddress);
    }

    function createERC1155Contract(string memory uri_) public returns (address deployedContractAddress) {
        deployedContractAddress = address(new ERC1155(uri_));
        emit ERC1155ContractDeployment(deployedContractAddress);
    }
}