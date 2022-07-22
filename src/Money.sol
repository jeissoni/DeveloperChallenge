// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract Money is ERC1155, Ownable {
    
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdCounter;   
    constructor(        
        _mint(msg.sender, 1, 50,"");        
        _mint(msg.sender, 5, 5,"");        
        _mint(msg.sender, 20 , 2,"");        
        _mint(msg.sender, 50, 2,"");        
        mint(msg.sender, 100, 20,"");
    ) ERC1155("") {}
    function exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId > tokenIdCounter.current() ? false : true ;
    }
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }
    function uri(uint256 _id) public view override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }
}