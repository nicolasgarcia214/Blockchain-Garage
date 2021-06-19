// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PokemonHubV2Hatchery is ERC1155 {
    uint256 public constant CHARMANDER = 0;
    uint256 public constant BULBASAUR = 1;
    uint256 public constant SQUIRTLE = 2;
    
    constructor() ERC1155("https://abcoathup.github.io/SampleERC1155/api/token/{id}.json") {
        _mint(msg.sender, CHARMANDER, 120, "");
        _mint(msg.sender, BULBASAUR, 120, "");
        _mint(msg.sender, SQUIRTLE, 120, "");
    }
}