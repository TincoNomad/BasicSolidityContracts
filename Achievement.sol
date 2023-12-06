//SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Achievement is ERC721("Token Achivement", "TA"), Ownable (msg.sender){

    uint lastIndex;

    function generate (address destination) public onlyOwner returns (uint){
        uint index = lastIndex;
        lastIndex ++;
        _safeMint(destination, index);
        return index;
    }
}