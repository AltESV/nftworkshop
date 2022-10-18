// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


//edit name of contract
contract Web3Builders is ERC1155, Ownable, Pausable, ERC1155Supply {


    //edit max supply of token
    uint256 public maxSupply = 100;

    bool public whiteListActive = false;

    //set limit for whitelisted user withdrawal
    uint256 limit = 1 ether;


    mapping (address => bool) public whiteList;

    constructor() ERC1155("ipfs://QmRgj3fm4N5azBVqmHBr3N9WYG4x79nvvGHhGxcUt9Er9r/") {}


    //allows anyone to deposit to smartcontract
    function deposit(uint256 amount) public payable {
        require(msg.value >0);
        amount = msg.value;
    }

    //allows only owner to set a new withdrawal limit for all whitelisted users
    function setLimit(uint256 _limit) public onlyOwner {
        limit = _limit;
    }

    //swtiches whitelist on or off in case we need to enable / disable access to minting and/or withdrawals
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

    //allows owner to add addresses to whitelist
    function setWhiteList(address[] calldata addresses) external onlyOwner {
            for (uint256 i = 0; i < addresses.length; i++) {
                whiteList[addresses[i]] = true;
            }
        }

    //allows owner to remove addresses from whitelist
     function removeFromWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            delete whiteList[addresses[i]];
        }
    }

    //allows anyone to mint unlimited number of token for free up to the max token supply amount need to switch this 
    //think about if we want to allow owner to mint unlimited amount at no cost and say external to limit up to max 3 tokenIDs for a price where price can be updated
    function mint(uint256 id, uint256 amount) public payable {
        _mint(msg.sender, id, amount, "");
        require(totalSupply(id) + amount <= maxSupply, "We have hit the cap.");
    }

    //allows whitelisted to withdraw a specified amount up to a certain limit (need to enable owner to set limit)
    function withdraw(address _addr, uint amount) external {
        require(whiteList[msg.sender], "Address not whitelisted.");
        uint256 balance = address(this).balance;
        require(amount <= balance);
        require(amount <= limit);
        payable(_addr).transfer(amount);
    }

    //allows owner to withdraw any amount
    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

   //erc1155 boiler plate functions for batch minting, transfer etc.
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
