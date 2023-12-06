//SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20("Price Token", "PT"), Ownable (msg.sender){

    function generate (uint amount, address destination) public onlyOwner {
        _mint(destination, amount);
    }
}