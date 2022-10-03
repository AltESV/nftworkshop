// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//add project name
contract nftdrop is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    
//added max supply
uint256 maxSupply = 20;

    Counters.Counter private _tokenIdCounter;

//add project name and token ticker symbol
    constructor() ERC721("fanacrew", "CREW") {}

//needs CID of JSON file on IPFS
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRgj3fm4N5azBVqmHBr3N9WYG4x79nvvGHhGxcUt9Er9r/";
        
    }

/*GAS saving techniques
1. enable optimization in compiler advanced settings
2. keep variables grouped together like here https://etherscan.io/address/0x28472a58a490c5e09a238847f66a68a47cc76f0f#code
*/

//mint function require payment, supply cap, allowing multiple mints
    function safeMint(uint256 amount) public payable {
        require(msg.value >= amount * 0.01 ether, "Not enough ETH sent.");
        uint256 tokenId = _tokenIdCounter.current();
        require(totalSupply() + amount <= maxSupply, "We have hit the cap.");
        //if you loop through supply instead of amount it will loop e.g. 20 times even if only 1 mint hit hence need to loop only as many times as people want to mint
        for(uint256 i; i < amount; i++){
            _safeMint(msg.sender, tokenId + i);
            _tokenIdCounter.increment();
        }
    }

//withdraw function from https://etherscan.io/address/0xd374410e9bb22f3771ffbd0b40a07c0cf44a04fc#code
    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
  }

//Ether , GEWI , WEI conversion here https://eth-converter.com/
//if payable in function need to pass into VALUE box correct amount of Gwei for transaction


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")) : ""; 
    }


    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

