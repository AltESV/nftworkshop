// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Web3Builders is ERC1155, Ownable, Pausable, ERC1155Supply {

    uint256 public maxSupply = 100;
    bool public whiteListActive = false;


    mapping (address => bool) public whiteList;

    constructor() ERC1155("ipfs://QmRgj3fm4N5azBVqmHBr3N9WYG4x79nvvGHhGxcUt9Er9r/") {}


    function setWhiteListActive(bool _whiteListActive) public onlyOwner {
        whiteListActive = _whiteListActive;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setWhiteList(address[] calldata addresses ) external onlyOwner {
            for (uint256 i = 0; i < addresses.length; i++) {
                whiteList[addresses[i]] = true;
            }
        }

    function mint(uint256 id, uint256 amount)
        public 
        payable
    {
        //check if whitelist active
        //require rule if whitelist active
        if(whiteListActive) {
            require(whiteList[msg.sender], "Address not whitelisted.");
        }
        require(msg.value >= amount * 0.01 ether, "Not enough ETH sent.");
        _mint(msg.sender, id, amount, "");
        require(totalSupply(id) + amount <= maxSupply, "We have hit the cap.");
    }

    function withdraw(address _addr) 
    external 
    onlyOwner 
    {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

   
   function uri(uint256 _id) public view override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

